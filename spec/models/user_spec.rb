require 'rails_helper'

RSpec.describe User, :type => :model do
  describe 'state_city parsing' do
    context 'valid city_state' do
      let(:user) {build :user, city_state: "Carnegie, PA", city: "", state: ""}

      it "gets city and state from 'Carnegie, PA'" do
        user.parse_city_state
        expect(user.city).to eq('Carnegie')
        expect(user.state).to eq('PA')
      end

      it "gets city and state from 'Carnegie PA" do
        user.city_state = 'Carnegie PA'
        user.parse_city_state
        expect(user.city).to eq('Carnegie')
        expect(user.state).to eq('PA')
      end

      #if we can detect there's just one element, see if it's the state
      it "gets the state from 'PA'" do
        user.city_state = 'PA'
        user.parse_city_state
        expect(user.city).to eq('')
        expect(user.state).to eq('PA')
      end

      it "gets the city and state from 'south bend ia'" do
        user.city_state = 'south bend ia'
        user.parse_city_state
        expect(user.city).to eq('South Bend')
        expect(user.state).to eq('IA')
      end

      it "gets the state from ', PA'" do
        user.city_state = ', PA'
        user.parse_city_state
        expect(user.city).to eq('')
        expect(user.state).to eq('PA')
      end
    end

    context 'invalid city_state' do
      let(:user) {build :user, city_state: "", city: "", state: ""}

      it "fails to parse 'Carnegie'" do
        user.city_state = 'Carnegie'
        user.parse_city_state
        expect(user.city).to eq('')
        expect(user.state).to eq('')
      end

      it "fails to parse 'Carnegie, '" do
        user.city_state = 'Carnegie, '
        user.parse_city_state
        expect(user.city).to eq('')
        expect(user.state).to eq('')
      end

      it "fails to parse a non-state" do
        user.city_state = 'Lincolnville, PO'
        user.parse_city_state
        expect(user.city).to eq('')
        expect(user.state).to eq('')
      end

      it "fails to parse an empty string" do
        expect(user.city_state).to eq('')
        user.parse_city_state
        expect(user.city).to eq('')
        expect(user.state).to eq('')
      end
    end
  end

  context 'validations' do
    it { should validate_length_of(:name).is_at_most(50)}
    it { should allow_value('lost of-fun & your ЖжДдѮѯ💩  jr.').for(:name)}
    it { should_not allow_value('Erin Germ">\'><img src=x onerror=alert(/v-name/)>r').for(:name)}
    it { should_not allow_value('fun"').for(:name)}
    it { should_not allow_value('fun@').for(:name)}
    it { should_not allow_value('fun
                                ').for(:name)}
    it { should validate_length_of(:phone_number).is_at_most(17)}
    it { should validate_length_of(:email).is_at_most(50)}
    it { should validate_length_of(:password).is_at_least(8).is_at_most(128)}
    it { should validate_length_of(:city).is_at_most(50)}
    it { should validate_length_of(:state).is_at_most(2)}
    it { should validate_length_of(:zip).is_at_most(12)}

    # shoulda-matchers doesn't really handle validations on derived fields that well
    it 'should validate uniquiness of phone_number_normalized' do
      first_user = create :user
      second_user = build :user

      second_user.phone_number = first_user.phone_number
      expect(second_user).to_not be_valid

      # junk at end of a phone_number gets stripped off during normalization
      second_user.phone_number = first_user.phone_number += '++'
      expect(second_user).to_not be_valid

      second_user.phone_number = '+18005555555'
      expect(second_user).to be_valid
    end

    describe '#permissible_state' do
      let(:user) {create :user}
      let(:admin_user) {create :admin_user}

      it 'is not valid if state is not supported' do
        user.zip = ''
        user.state = 'XX'
        expect(user).to_not be_valid
        expect(user.errors[:state]).to include('isn\'t a supported state.')
      end

      it 'is valid if state is supported' do
        user.zip = ''
        user.state = User::VALID_STATES.keys.first
        expect(user).to be_valid
      end

      # The two char validation on 'state' prevents this from being possible,
      # leavint around for the time being until we verify desired behavior
      # it 'is valid if state is supported, but has surrounding whitespace' do
      #   user.zip = ''
      #   user.state = "#{User::VALID_STATES.keys.first} "
      #   expect(user).to be_valid
      # end

      it 'is valid regardless of state, if user is admin' do
        admin_user.state = 'XX' # zip not in state on approved list
        expect(admin_user).to be_valid
      end

      it 'is valid if state is empty' do
        user.zip = nil
        user.state = nil
        expect(user).to be_valid
      end
    end

    describe '#permissible_zip' do
      let(:user) {create :user}
      let(:admin_user) {create :admin_user}
      before(:all) do
        ZipCodes.load
      end

      it 'is not valid if zipcode not in supported state' do
        user.zip = '04101' # zip not in state on approved list
        expect(user).to_not be_valid
        expect(user.errors[:zip]).to include('isn\'t in a supported state.')
      end

      it 'is valid if zip in supported state' do
        user.zip = 15106 # Carnegie, PA
        expect(user).to be_valid
      end

      it 'is valid regardless of zipcode, if user is admin' do
        admin_user.zip = 90026 # zip not in state on approved list
        expect(admin_user).to be_valid
      end

      it 'is valid if zip is empty' do
        user.zip = nil
        expect(user).to be_valid
      end
    end
  end

  describe '#add_rolify_role' do
    let(:valid_attributes) {
      {name: 'Rolify Test Uaer', email: 'foo@bar.com', password: '12345abcde', phone_number: '2073328710', city: 'Tolendo', state: 'PA', zip: '15106'}
    }

    it "doesn't allow the creation of super admins" do
      user = User.new(valid_attributes)
      user.user_type = 'admin'

      expect{user.save}.to raise_error("Bad role, model.")
    end

  end

  describe 'lifecycle hooks' do
    describe 'after_validation geocode' do
      let(:user) { create :user }
      it 'should set lat/long on user create' do
        expect(user.latitude).to_not be_nil
        expect(user.longitude).to_not be_nil
      end

      it 'should not change set lat/long on user save' do
        original_lat = user.latitude
        original_long = user.longitude

        user.address1 = '5001 Monroe St'
        user.address2 = ''
        user.city = 'Carnegie'
        user.state = 'PA'
        user.zip = 15106

        user.save!
        user.reload

        expect(user.latitude).to eq(original_lat)
        expect(user.longitude).to eq(original_long)
      end
    end
  end

  it 'should allow no role' do
    expect( build(:user) ).to be_valid
  end

  it 'should only allow valid roles' do
    expect( build(:user, user_type: 'bad_role') ).to_not be_valid
  end

  it 'removes :unassigned_driver role when made :driver' do
    rz = create :ride_zone
    u = create :unassigned_driver_user, rz: rz

    expect( u.has_role?(:unassigned_driver, :any) ).to be_truthy
    expect( u.has_role?(:driver, rz) ).to be_falsy

    u.add_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver, :any) ).to be_falsy
    expect( u.has_role?(:driver, rz) ).to be_truthy
  end

  it 'adds back :unassigned_driver when :driver is removed' do
    u = create :user
    rz = create :ride_zone
    u.add_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver) ).to be_falsy
    expect( u.has_role?(:driver, rz) ).to be_truthy

    u.remove_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver, rz) ).to be_truthy
    expect( u.has_role?(:driver, rz) ).to be_falsy
  end

  it 'is invalid with a non-permissible zip' do
   expect( build(:user, zip: '04101') ).to_not be_valid
  end

  it 'returns driver ride zone' do
    rz = create :ride_zone
    u = create :driver_user, rz: rz
    expect(u.reload.driver_ride_zone_id).to eq(rz.id)
  end

  it 'updates location timestamp for lat change' do
    u = create :user
    original_location_updated_at = u.location_updated_at
    u.update_attribute :latitude, 34
    expect(u.reload.location_updated_at).to_not eq(original_location_updated_at)
  end

  it 'updates location timestamp for long change' do
    u = create :user
    u.update_attribute :longitude, -122
    expect(u.reload.location_updated_at).to_not be_nil
  end

  describe 'enqueues email' do
    let(:dummy_mailer) { OpenStruct.new(deliver_later: nil) }

    it 'sends driver email for web registration' do
      expect(UserMailer).to receive(:welcome_email_driver) { dummy_mailer }
      create :driver_user, user_type: :driver
    end

    it 'does not send email for sms voter' do
      expect(UserMailer).to_not receive(:welcome_email_voter)
      create :sms_voter_user
    end

    it 'sends driver email when approved' do
      rz = create :ride_zone
      u = create :unassigned_driver_user, rz: rz

      expect(UserMailer).to receive(:notify_driver_approved) { dummy_mailer }
      u.add_role(:driver, rz)
    end
  end

  describe 'event generation' do
    let(:rz) { create :ride_zone }

    it 'does not send event for new voter' do
      expect(RideZone).to_not receive(:event)
      create :voter_user, rz: rz
    end

    it 'does not send event for updated voter' do
      u = create :voter_user, rz: rz
      expect(RideZone).to_not receive(:event)
      u.update_attribute(:name, 'foobar')
    end

    it 'sends new driver event' do
      expect(RideZone).to receive(:event).with(anything, :new_driver, anything, :driver)
      # cannot use factory because it doesn't create users the same way code
      # does with transient attributes
      User.create! name: 'foo', user_type: 'driver', ride_zone: rz, email: 'foo@example.com', phone_number: '+14155555555', phone_number_normalized: '+14155555555', password: '123456789'
    end

    it 'sends driver update event on change' do
      d = create :driver_user, rz: rz
      expect(RideZone).to receive(:event).with(rz.id, :driver_changed, anything, :driver)
      d.update_attribute(:name, 'foo bar')
    end
  end

  describe 'qa_clear and destroy' do
    let(:user) { create :user }
    let(:convo) { create :conversation_with_messages, user: user }
    let(:ride) { Ride.create_from_conversation(convo) }

    it 'deletes all user conversation data on qa_clear' do
      cid, rid = convo.id, ride.id
      user.qa_clear
      expect(Ride.find_by_id(rid)).to be_nil
      expect(Message.where(conversation_id: cid).count).to eq(0)
      expect(Conversation.find_by_id(cid)).to be_nil
    end

    it 'deletes all user conversation data on destroy' do
      cid, rid = convo.id, ride.id
      user.destroy
      expect(Ride.find_by_id(rid)).to be_nil
      expect(Message.where(conversation_id: cid).count).to eq(0)
      expect(Conversation.find_by_id(cid)).to be_nil
    end
  end

  describe 'role checks' do

    describe 'for voters' do
      let(:voter) { create :voter_user }
      let(:non_voter) { create :user }

      it "knows if you're a voter" do
        expect( voter.is_voter? ).to eq(true)
      end

      it "knows if you're not a voter" do
        expect( non_voter.is_voter? ).to eq(false)
      end
    end

    describe 'for unassigned drivers' do
      let(:unassigned_driver) { create :unassigned_driver_user }
      let(:non_driver) { create :user }

      it "knows if you're an unassigned driver" do
        expect( unassigned_driver.is_unassigned_driver? ).to eq(true)
      end

      it "knows if you're not an unassigned driver" do
        expect( non_driver.is_unassigned_driver? ).to eq(false)
      end

      it "knows a non-driver is not just an unassigned driver" do
        expect( non_driver.is_only_unassigned_driver? ).to eq(false)
      end

      it "knows if an unassigned driver has only that role" do
        expect( unassigned_driver.is_only_unassigned_driver? ).to eq(true)
      end
    end

    describe 'for drivers' do
      let(:driver) { create :driver_user }
      let(:non_driver) { create :user }

      it "knows if you're a driver" do
        expect( driver.is_driver? ).to eq(true)
      end

      it "knows if you're not a driver" do
        expect( non_driver.is_driver? ).to eq(false)
      end

      it "knows a driver fails is_only_unassigned_driver?" do
        expect( driver.is_only_unassigned_driver? ).to eq(false)
      end
    end

    describe 'for dispatchers' do
      let(:dispatcher) { create :dispatcher_user }
      let(:non_dispatcher) { create :user }

      it "knows if you're a dispatcher" do
        expect( dispatcher.is_dispatcher? ).to eq(true)
      end

      it "knows if you're not a dispatcher" do
        expect( non_dispatcher.is_dispatcher? ).to eq(false)
      end

      it "knows a dispatcher fails is_only_unassigned_driver?" do
        expect( dispatcher.is_only_unassigned_driver? ).to eq(false)
      end
    end

    describe 'for zone admins' do
      let(:zone_admin) { create :zoned_admin_user }
      let(:non_zone_admin) { create :user }

      it "knows if you're a zone admin" do
        expect( zone_admin.is_zone_admin? ).to eq(true)
      end

      it "knows if you're not a zone admin" do
        expect( non_zone_admin.is_zone_admin? ).to eq(false)
      end
    end
  end

  describe 'rides' do
    let(:user) { create :voter_user }

    it 'returns active and open ride' do
      r = create :assigned_ride, voter: user
      expect(user.active_ride.id).to eq(r.id)
      expect(user.open_ride.id).to eq(r.id)
    end

    it 'does not returns active and open ride' do
      create :complete_ride, voter: user
      create :canceled_ride, voter: user
      expect(user.active_ride).to be_nil
      expect(user.open_ride).to be_nil
    end
  end

  it 'marks info complete' do
    u = create :user, name: '+15105261111 via sms', phone_number: '+15105261111'
    expect(u.has_sms_name?).to be_truthy
    expect(u.language).to eq('unknown')
    u.mark_info_completed
    expect(u.reload.has_sms_name?).to be_falsey
    expect(u.language).to eq('en')
  end

  it 'produces safe html' do
    u = create :user, name: '&'
    expect(u.api_json['name']).to eq('&amp;')
  end
end
