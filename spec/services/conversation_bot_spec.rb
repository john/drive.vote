require 'rails_helper'

RSpec.describe ConversationBot do
  let(:convo) { create :conversation_with_messages }
  let(:msg) { create :message, conversation: convo }
  let(:ride_address_attrs) {{from_address: '106 Dunbar Avenue', from_city: 'Carnegie',
                             from_latitude: 40.409, from_longitude: -80.090,
                             to_address: 'to', to_city: 'tcity', to_latitude: 3, to_longitude: 4}}

  it 'has methods for each conversation lifecycle' do
    cb = ConversationBot.new(convo, msg)
    methods = cb.private_methods - Object.private_methods
    expect(Conversation.lifecycles.keys.map(&:to_sym) - methods).to eq([])
  end

  describe 'newly created conversation needing language' do
    it 'should thank and request language' do
      expect(ConversationBot.new(convo, msg).response).to include('Thanks')
      expect(convo.reload.bot_counter).to eq(1)
    end

    {
      :en => ['1', 'english', 'i speak English'],
      :es => ['2', 'espanol', 'español', 'yo hablo español']
    }.each do |lang, list|
      list.each do |body|
        it "should handle reply of #{body} for English" do
          convo.user.update_attribute :name, ''
          ConversationBot.new(convo, msg).response # do initial response
          voter_reply = create :message, conversation: convo, body: body
          expect(ConversationBot.new(convo, voter_reply).response).to include(I18n.t(:name, locale: lang).downcase)
          expect(convo.reload.bot_counter).to eq(0)
          expect(convo.lifecycle).to eq('have_language')
          expect(convo.user.reload.language).to eq(lang.to_s)
        end
      end
    end

    it 'should handle bad replies' do
      convo.user.update_attribute :name, ''
      ConversationBot.new(convo, msg).response # do initial response, counter is now at 1
      bad_reply = create :message, conversation: convo, body: 'what???'
      expect(ConversationBot.new(convo, bad_reply).response).to include('Sorry') # don't know language yet
      expect(convo.reload.bot_counter).to eq(2)
      expect(ConversationBot.new(convo, bad_reply).response).to include('Sorry') # don't know language yet
      expect(convo.reload.bot_counter).to eq(3)
      expect(ConversationBot.new(convo, bad_reply).response).to include('contact') # don't know language yet
      expect(convo.reload.bot_counter).to eq(3)
      expect(ConversationBot.new(convo, bad_reply).response).to include('contact') # don't know language yet
      expect(convo.reload.bot_counter).to eq(3)
    end
  end

  describe 'getting name' do
    let(:user) { create :user, language: :en, name: '' }
    let(:convo) { create :conversation_with_messages, user: user }

    it 'should accept and update name' do
      reply = create :message, conversation: convo, body: 'george washington'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:what_is_pickup_location, locale: :en, name: 'george'))
      expect(convo.reload.lifecycle).to eq('have_name')
      expect(convo.user.reload.name).to eq('george washington')
    end

    it 'should reject empty name' do
      reply = create :message, conversation: convo, body: '  '
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:empty_need_name, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:empty_need_name, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
    end
  end

  describe 'special case of new conversation registered user' do
    let(:user) { create :user, language: :en, name: 'george washington' }
    let(:convo) { create :conversation, user: user }

    it 'should ignore message and prompt for origin' do
      reply = create :message, conversation: convo, body: 'hi there', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:what_is_pickup_location, locale: :en, name: 'george'))
      expect(convo.reload.lifecycle).to eq('have_name')
      expect(convo.status).to eq('in_progress')
    end
  end

  describe 'prior complete ride' do
    let!(:user) { create :user, language: :en, name: 'foo bar' }
    let!(:ride) { create :ride, {voter: user, status: :complete}.merge(ride_address_attrs) }
    let!(:convo) { create :conversation_with_messages, user: user }

    before :each do
      reply = create :message, conversation: convo, body: 'can I get a ride back?'
      expected = I18n.t(:are_you_going_from_to, locale: :en, from: ride_address_attrs[:to_address], to: ride_address_attrs[:from_address])
      expect(ConversationBot.new(convo, reply).response).to eq(expected)
    end

    %w(y yes si sí).each do |answer|
      it "accepts a yes answer of #{answer}" do
        reply = create :message, conversation: convo, body: answer
        expected = I18n.t(:when_do_you_want_pickup, locale: :en)
        expect(ConversationBot.new(convo, reply).response).to eq(expected)
        expect(convo.reload.lifecycle).to eq('have_confirmed_destination')
      end
    end

    it 'accepts a non-yes answer and asks for origin' do
      reply = create :message, conversation: convo, body: 'no'
      expected = I18n.t(:what_is_pickup_location, locale: :en, name: convo.username.split(' ').first)
      expect(ConversationBot.new(convo, reply).response).to eq(expected)
      expect(convo.reload.lifecycle).to eq('have_name')
    end
  end

  shared_examples 'handles bad geocoding' do
    it 'should reject too many results' do
      allow(GooglePlaces).to receive(:search).and_return([good_geocode, good_geocode])
      reply = create :message, conversation: convo, body: 'fake address'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:too_many_addresses, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:too_many_addresses, locale: :en))
      if type == :from
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:too_many_addresses, locale: :en))
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      else
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:no_dest_when_do_you_want_pickup, locale: :en))
      end
    end

    it 'should reject no results' do
      allow(GooglePlaces).to receive(:search).and_return([])
      reply = create :message, conversation: convo, body: 'fake address'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:no_address_match, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:no_address_match, locale: :en))
      if type == :from
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:no_address_match, locale: :en))
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      else
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:no_dest_when_do_you_want_pickup, locale: :en))
      end
    end

    it 'should reject too far away' do
      allow(GooglePlaces).to receive(:search).and_return([good_geocode])
      allow_any_instance_of(RideZone).to receive(:is_within_pickup_radius?).and_return(false)
      reply = create :message, conversation: convo, body: 'fake address'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:ride_too_far, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:ride_too_far, locale: :en))
      if type == :from
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:ride_too_far, locale: :en))
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      else
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:no_dest_when_do_you_want_pickup, locale: :en))
      end
    end
  end

  describe 'getting to confirmed origin' do
    let(:user) { create :user, language: :en, name: 'foo' }
    let(:convo) { create :conversation_with_messages, user: user }
    let(:good_geocode) { {'formatted_address' => '106 Dunbar Avenue, Carnegie, PA 15106, United States', 'geometry' => {'location' => {'lat' => 1, 'lng' => 2}} } }

    before :each do
      allow(GooglePlaces).to receive(:search).and_return([good_geocode])
      allow_any_instance_of(RideZone).to receive(:is_within_pickup_radius?).and_return(true)
    end

    it 'should accept valid address, update conversation, and confirm' do
      reply = create :message, conversation: convo, body: 'fake address'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:confirm_address, locale: :en, address: '106 Dunbar Avenue, Carnegie'))
      expect(convo.reload.lifecycle).to eq('have_origin')
      expect(convo.from_address).to eq('106 Dunbar Avenue, Carnegie')
      expect(convo.from_city).to eq('Carnegie')
      expect(convo.from_latitude).to eq(1)
      expect(convo.from_longitude).to eq(2)
    end

    it 'should echo name if present' do
      allow(GooglePlaces).to receive(:search).and_return([good_geocode.merge('name' => 'school')])
      reply = create :message, conversation: convo, body: 'fake address'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:confirm_address, locale: :en, address: 'school - 106 Dunbar Avenue, Carnegie'))
    end

    it 'should confirm address' do
      reply = create :message, conversation: convo, body: 'fake address'
      ConversationBot.new(convo, reply).response # get confirmation
      reply = create :message, conversation: convo, body: 'y'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:what_is_destination_location, locale: :en))
      expect(convo.reload.lifecycle).to eq('have_confirmed_origin')
      expect(convo.from_confirmed).to be_truthy
    end

    it 'should go back if not confirmed' do
      reply = create :message, conversation: convo, body: 'fake address'
      ConversationBot.new(convo, reply).response # get confirmation
      reply = create :message, conversation: convo, body: 'n'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:what_is_pickup_location, locale: :en, name: 'foo'))
      expect(convo.reload.lifecycle).to eq('have_name')
      expect(convo.from_latitude).to be_nil
      expect(convo.from_longitude).to be_nil
      expect(convo.from_confirmed).to be_falsey
    end

    it_behaves_like 'handles bad geocoding' do
      let!(:type) { :from }
    end
  end

  describe 'getting to confirmed destination' do
    let(:user) { create :user, language: :en, name: 'foo' }
    let(:convo) { create :conversation_with_messages, user: user, from_latitude: 40.409, from_longitude: -80.090, from_confirmed: true }
    let(:good_geocode) { {'formatted_address' => '106 Dunbar Avenue, Carnegie, PA 15106, United States', 'geometry' => {'location' => {'lat' => 40.4, 'lng' => -80.1}} } }

    before :each do
      allow(GooglePlaces).to receive(:search).and_return([good_geocode])
    end

    it 'should accept valid address, update conversation, and confirm' do
      reply = create :message, conversation: convo, body: 'fake address'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:confirm_address, locale: :en, address: '106 Dunbar Avenue, Carnegie'))
      expect(convo.reload.lifecycle).to eq('have_destination')
      expect(convo.to_address).to eq('106 Dunbar Avenue, Carnegie')
      expect(convo.to_city).to eq('Carnegie')
      expect(convo.to_latitude.to_f).to eq(40.4)
      expect(convo.to_longitude.to_f).to eq(-80.1)
    end

    it 'should echo name if present' do
      allow(GooglePlaces).to receive(:search).and_return([good_geocode.merge('name' => 'school')])
      reply = create :message, conversation: convo, body: 'fake address'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:confirm_address, locale: :en, address: 'school - 106 Dunbar Avenue, Carnegie'))
    end

    it 'should confirm address' do
      reply = create :message, conversation: convo, body: 'fake address'
      ConversationBot.new(convo, reply).response # get confirmation
      reply = create :message, conversation: convo, body: 'y'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:when_do_you_want_pickup, locale: :en))
      expect(convo.reload.lifecycle).to eq('have_confirmed_destination')
      expect(convo.to_confirmed).to be_truthy
    end

    it 'should go back for destination if not confirmed' do
      reply = create :message, conversation: convo, body: 'fake address'
      ConversationBot.new(convo, reply).response # get confirmation
      reply = create :message, conversation: convo, body: 'n'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:what_is_destination_location, locale: :en, name: 'foo'))
      expect(convo.reload.lifecycle).to eq('have_confirmed_origin')
      expect(convo.to_latitude).to be_nil
      expect(convo.to_longitude).to be_nil
      expect(convo.to_confirmed).to be_falsey
    end

    it "should handle don't know reply" do
      reply = create :message, conversation: convo, body: "i don't know"
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:no_dest_when_do_you_want_pickup, locale: :en))
      expect(convo.reload.lifecycle).to eq('have_confirmed_destination')
      expect(convo.to_address).to eq(Conversation::UNKNOWN_ADDRESS)
      expect(convo.to_confirmed).to be_truthy
    end

    it_behaves_like 'handles bad geocoding' do
      let!(:type) { :to }
    end
  end

  describe 'getting to confirmed time' do
    let(:user) { create :user, language: :en, name: 'foo' }
    let(:convo) { create :conversation_with_messages, user: user, from_latitude: 40.409, from_longitude: -80.090, from_confirmed: true, to_latitude: 1, to_longitude: 2, to_confirmed: true }
    let(:voter_time) { Time.use_zone(convo.ride_zone.time_zone) do 10.minutes.from_now.change(sec:0, usec:0); end }
    let(:voter_formatted) { voter_time.strftime('%l:%M %P')}

    describe 'valid times' do
      around :each do |example|
        Timecop.travel(Time.parse('12:00 pm')) do
          example.run
        end
      end

      it 'should accept valid time, update conversation, and confirm' do
        reply = create :message, conversation: convo, body: voter_formatted
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:confirm_the_time, locale: :en, time: voter_formatted))
        expect(convo.reload.lifecycle).to eq('have_time')
        expect(convo.pickup_at.to_i).to eq(voter_time.to_i)
      end

      it 'should confirm time' do
        reply = create :message, conversation: convo, body: voter_formatted
        ConversationBot.new(convo, reply).response # get confirmation
        reply = create :message, conversation: convo, body: 'y'
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:how_many_additional, locale: :en))
        expect(convo.reload.lifecycle).to eq('have_confirmed_time')
        expect(convo.time_confirmed).to be_truthy
      end

      it 'should go back if not confirmed' do
        reply = create :message, conversation: convo, body: voter_formatted
        ConversationBot.new(convo, reply).response # get confirmation
        reply = create :message, conversation: convo, body: 'n'
        expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:when_do_you_want_pickup, locale: :en))
        expect(convo.reload.lifecycle).to eq('have_confirmed_destination')
        expect(convo.pickup_at).to be_nil
        expect(convo.time_confirmed).to be_falsey
      end
    end

    it 'should reject bad time' do
      reply = create :message, conversation: convo, body: 'huh'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:invalid_time, locale: :en))
      expect(convo.reload.lifecycle).to eq('have_confirmed_destination')
      expect(convo.pickup_at).to be_nil
    end
  end

  describe 'additional passengers' do
    let!(:user) { create :user, language: :en, name: 'foo' }
    let!(:convo) { create :conversation_with_messages, user: user, from_latitude: 40.409, from_longitude: -80.090, from_confirmed: true, to_latitude: 1, to_longitude: 2, to_confirmed: true, pickup_at: Time.now, time_confirmed: true }

    ConversationBot::NUMBER_STRINGS.each do |num, list|
      list.each do |regexp|
        it "should accept #{regexp.source} passengers" do
          reply = create :message, conversation: convo, body: regexp.source
          expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:any_special_requests, locale: :en))
          expect(convo.reload.lifecycle).to eq('have_passengers')
          expect(convo.additional_passengers).to eq(num)
        end
      end
    end

    it 'should reject bad numbers' do
      reply = create :message, conversation: convo, body: 'infinity'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:invalid_passengers, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:invalid_passengers, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
    end
  end

  describe 'special requests' do
    let!(:user) { create :user, language: :en, name: 'foo' }
    let!(:convo) { create :conversation_with_messages, user: user, from_latitude: 40.409, from_longitude: -80.090, from_confirmed: true, to_latitude: 1, to_longitude: 2, to_confirmed: true, pickup_at: Time.now, time_confirmed: true, additional_passengers:0 }

    it 'should accept special requests' do
      reply = create :message, conversation: convo, body: 'wheelchair'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:thanks_wait_for_driver, locale: :en))
      expect(convo.reload.lifecycle).to eq('info_complete')
      expect(convo.special_requests).to eq('wheelchair')
      expect(convo.status).to eq('ride_created')
      expect(convo.ride).to_not be_nil
    end
  end

  describe 'confirmation' do
    let!(:user) { create :user, language: :en, name: 'foo' }
    let!(:convo) { create :complete_conversation, user: user, ride_confirmed: false }
    let!(:ride) { Ride.create_from_conversation(convo) }
    let(:voter_time) { Time.use_zone(convo.ride_zone.time_zone) do 10.minutes.from_now.change(sec:0, usec:0); end }
    let(:voter_formatted) { voter_time.strftime('%l:%M %P')}

    it 'should accept ride confirmation' do
      expect(convo.lifecycle).to eq('requested_confirmation')
      reply = create :message, conversation: convo, body: '1', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:thanks_wait_for_driver, locale: :en))
      expect(convo.reload.lifecycle).to eq('info_complete')
      expect(convo.ride_confirmed).to eq(true)
      expect(convo.ride.reload.status).to eq('waiting_assignment')
    end

    it 'should accept ride reschedule' do
      reply = create :message, conversation: convo, body: '2', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:when_do_you_want_pickup, locale: :en))
      expect(convo.reload.lifecycle).to eq('have_confirmed_destination')
      expect(convo.ride_confirmed).to eq(false)
    end

    it 'should reschedule, confirm, then go to waiting' do
      reply = create :message, conversation: convo, body: '2', from: convo.from_phone, to: convo.to_phone
      ConversationBot.new(convo, reply).response # prompt for time
      reply = create :message, conversation: convo, body: voter_formatted, from: convo.from_phone, to: convo.to_phone
      ConversationBot.new(convo, reply).response # get confirmation
      reply = create :message, conversation: convo, body: 'y', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:thanks_wait_for_driver, locale: :en))
      expect(convo.reload.lifecycle).to eq('info_complete')
    end

    it 'should accept ride cancel' do
      reply = create :message, conversation: convo, body: '3', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:thanks_for_using, locale: :en))
      expect(convo.reload.status).to eq('closed')
      expect(convo.ride.status).to eq('complete')
    end

    it 'should accept confirm help needed' do
      reply = create :message, conversation: convo, body: '4', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      expect(convo.reload.status).to eq('help_needed')
    end

    it 'should ask twice for confirmation' do
      reply = create :message, conversation: convo, body: 'huh', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:confirm_ride, locale: :en, time: convo.ride.pickup_in_time_zone.strftime('%l:%M %P')))
      reply = create :message, conversation: convo, body: 'huh', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:confirm_ride, locale: :en, time: convo.ride.pickup_in_time_zone.strftime('%l:%M %P')))
      reply = create :message, conversation: convo, body: 'huh', from: convo.from_phone, to: convo.to_phone
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      expect(convo.reload.status).to eq('help_needed')
    end
  end

  describe 'unexpected after all done' do
    let!(:user) { create :user, language: :en, name: 'foo' }
    let!(:convo) { create :conversation_with_messages, user: user, from_latitude: 40.409, from_longitude: -80.090, from_confirmed: true, to_latitude: 1, to_longitude: 2, to_confirmed: true, pickup_at: Time.now, time_confirmed: true, additional_passengers:0, special_requests: 'none' }

    it 'should signal for help' do
      reply = create :message, conversation: convo, body: 'wait i made a mistake'
      expect(ConversationBot.new(convo, reply).response).to eq(I18n.t(:bot_stalled, locale: :en))
      expect(convo.reload.lifecycle).to eq('info_complete')
      expect(convo.status).to eq('help_needed')
    end
  end
end
