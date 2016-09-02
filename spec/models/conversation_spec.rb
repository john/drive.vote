require 'rails_helper'

RSpec.describe Conversation, type: :model do
  it_behaves_like 'to_from_addressable'

  let(:ride_address_attrs) {{from_address: 'from', from_city: 'fcity', from_latitude: 1, from_longitude: 2,
                             to_address: 'to', to_city: 'tcity', to_latitude: 3, to_longitude: 4}}
  let(:full_address_attrs) { {from_latitude: 34.5, from_longitude: -122.6, from_confirmed: true, to_latitude: 34.5, to_longitude: -122.6, to_confirmed: true} }

  describe 'validations' do
    describe 'phone_numbers_match_first_message' do
      let(:convo) { create :conversation}

      context 'Conversation has no messages' do
        it 'should be valid' do
          expect(convo.messages.count).to eq(0)
          convo.to_phone = nil
          convo.from_phone = nil
          expect(convo).to be_valid
          end
      end

      context 'Conversation has messages' do
        context 'message to/from match' do
          it 'should be valid' do
            create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone
            create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone

            expect(convo).to be_valid
          end
        end
      end

      context 'message to/from do not match' do
        it 'should be valid' do
          create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone
          create :message, conversation: convo, to: convo.to_phone, from: convo.from_phone

          convo.to_phone = '111-111-1111'
          convo.from_phone ='222-222-2222'

          expect(convo).to_not be_valid
        end
      end
    end
  end

  describe 'lifecycle hooks' do

    describe 'saving status' do
      let(:user) { create :user, language:1, name: 'foo' }

      it 'writes lifecycle to db' do
        c = create :conversation, user: user
        expect(c.reload.lifecycle).to eq('have_name')
      end

      it 'auto updates status' do
        c = create :conversation, user: user, status: :sms_created
        c.reload.update_attribute(:additional_passengers, 2)
        expect(c.reload.status).to eq('in_progress')
      end
    end
  end

  describe 'new conversation from staff' do
    let(:rz) { create :ride_zone }
    let(:user) { create :driver_user, ride_zone: rz }
    let(:body) { 'can you go to south side?' }
    let(:twilio_msg) { OpenStruct.new(error_code: nil, status: 'delivered', body: body, sid: 'sid') }

    before :each do
      allow(TwilioService).to receive(:send_message).and_return(twilio_msg)
    end

    it 'calls twilio service' do
      expect(TwilioService).to receive(:send_message).and_return(twilio_msg)
      Conversation.create_from_staff(rz, user, body, 5)
    end

    it 'handles twilio error' do
      expect(TwilioService).to receive(:send_message).and_return(OpenStruct.new(error_code: 123))
      expect(Conversation.create_from_staff(rz, user, body, 5) =~ /Communication error/).to be_truthy
      expect(Conversation.count).to eq(0)
    end

    it 'creates a conversation and message' do
      Conversation.create_from_staff(rz, user, body, 5)
      expect(Conversation.count).to eq(1)
      expect(Conversation.last.staff_initiated?).to be_truthy
      msg = Conversation.last.messages.last
      expect(msg.sent_by).to eq('Staff')
      expect(msg.body).to eq(body)
    end
  end

  describe 'event generation' do
    it 'sends new conversation event' do
      expect(RideZone).to receive(:event).with(anything, :new_conversation, anything)
      create :conversation
    end

    it 'sends conversation update event' do
      c = create :conversation
      expect(RideZone).to receive(:event).with(c.ride_zone_id, :conversation_changed, anything)
      c.update_attribute(:status, :closed)
    end
  end

  it 'updates status on ride assignment' do
    r = create :ride
    c = create :conversation
    r.conversation = c
    expect(c.reload.status).to eq('ride_created')
  end

  it 'inverts ride addresses' do
    r = create :ride, ride_address_attrs
    c = create :conversation
    c.invert_ride_addresses(r)
    c.reload
    expect(c.from_address).to eq('to')
    expect(c.from_city).to eq('tcity')
    expect(c.from_latitude).to eq(3)
    expect(c.from_longitude).to eq(4)
    expect(c.to_address).to eq('from')
    expect(c.to_city).to eq('fcity')
    expect(c.to_latitude).to eq(1)
    expect(c.to_longitude).to eq(2)
  end

  it 'updates status timestamp on create' do
    c = create :conversation
    expect(c.reload.status_updated_at).to_not be_nil
  end

  it 'updates status timestamp on status change' do
    c = Timecop.travel(1.hour.ago) do
      create :conversation
    end
    c.update_attribute(:status, :closed)
    expect(Time.now - c.reload.status_updated_at).to be <(10)
  end

  describe 'lifecycle calculation' do
    it 'detects newly created' do
      c = create :conversation
      expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:created])
    end

    it 'detects language exists' do
      c = create :conversation
      c.user.update_attributes language: 1, name: ''
      expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_language])
    end

    describe 'user attributes known' do
      let(:user) { create :user, language: 1, name: 'foo' }

      it 'detects language and name exist' do
        c = create :conversation, user: user
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_name])
      end

      it 'detects existing ride' do
        create :ride, {voter: user, status: :complete}.merge(ride_address_attrs)
        c = create :conversation, user: user
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_prior_ride])
      end

      it 'ignores existing ride to unknown destination' do
        create :ride, {voter: user, status: :complete}.merge(ride_address_attrs).merge(to_address: Ride::UNKNOWN_ADDRESS)
        c = create :conversation, user: user
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_name])
      end

      it 'detects existing ride has been copied' do
        r = create :ride, {voter: user, status: :complete}.merge(ride_address_attrs)
        c = create :conversation, user: user
        c.invert_ride_addresses(r)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_confirmed_destination])
      end

      it 'detects origin exists' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_origin])
      end

      it 'detects confirmed origin' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6, from_confirmed: true
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_confirmed_origin])
      end

      it 'detects unknown destination' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6, from_confirmed: true
        c.set_unknown_destination
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_confirmed_destination])
      end

      it 'detects destination exists' do
        c = create :conversation, user: user, from_latitude: 34.5, from_longitude: -122.6, from_confirmed: true, to_latitude: 34.5, to_longitude: -122.6
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_destination])
      end

      it 'detects confirmed destination' do
        c = create :conversation, {user: user}.merge(full_address_attrs)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_confirmed_destination])
      end

      it 'detects time exists' do
        c = create :conversation, {user: user}.merge(full_address_attrs).merge(pickup_time: Time.now)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_time])
      end

      it 'detects time confirmed' do
        c = create :conversation, {user: user}.merge(full_address_attrs).merge(pickup_time: Time.now, time_confirmed: true)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_confirmed_time])
      end

      it 'detects passengers' do
        c = create :conversation, {user: user}.merge(full_address_attrs).merge(pickup_time: Time.now, time_confirmed: true, additional_passengers: 0)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_passengers])
      end

      it 'detects time exists unknown dest' do
        c = create :conversation, {user: user}.merge(full_address_attrs).merge(pickup_time: Time.now).merge(to_address: Conversation::UNKNOWN_ADDRESS)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_time])
      end

      it 'detects time confirmed unknown dest' do
        c = create :conversation, {user: user}.merge(full_address_attrs).merge(pickup_time: Time.now, time_confirmed: true).merge(to_address: Conversation::UNKNOWN_ADDRESS)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_confirmed_time])
      end

      it 'detects passengers unknown dest' do
        c = create :conversation, {user: user}.merge(full_address_attrs).merge(pickup_time: Time.now, time_confirmed: true, additional_passengers: 0).merge(to_address: Conversation::UNKNOWN_ADDRESS)
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:have_passengers])
      end

      it 'detects complete' do
        c = create :complete_conversation, user: user
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:info_complete])
      end

      it 'detects complete unknown dest' do
        c = create :complete_conversation, user: user, to_address: Conversation::UNKNOWN_ADDRESS
        expect(c.send(:calculated_lifecycle)).to eq(Conversation.lifecycles[:info_complete])
      end
    end
  end
end
