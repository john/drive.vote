require 'rails_helper'

RSpec.describe User, :type => :model do

  context 'validations' do
    it { should validate_presence_of :email }
    it { should validate_length_of(:phone_number).is_at_most(17)}
    it { should validate_length_of(:email).is_at_most(50)}
    it { should validate_length_of(:password).is_at_least(8).is_at_most(50)}
    it { should validate_length_of(:city).is_at_most(50)}
    it { should validate_length_of(:state).is_at_most(2)}
    it { should validate_length_of(:zip).is_at_most(12)}

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
        user.zip = 90026 # zip not in state on approved list
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
    u = create :unassigned_driver_user
    rz = create :ride_zone

    expect( u.has_role?(:unassigned_driver) ).to be_truthy
    expect( u.has_role?(:driver, rz) ).to be_falsy

    u.add_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver) ).to be_falsy
    expect( u.has_role?(:driver, rz) ).to be_truthy
  end

  it 'adds back :unassigned_driver when :driver is removed' do
    u = create :user
    rz = create :ride_zone
    u.add_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver) ).to be_falsy
    expect( u.has_role?(:driver, rz) ).to be_truthy

    u.remove_role(:driver, rz)

    expect( u.has_role?(:unassigned_driver) ).to be_truthy
    expect( u.has_role?(:driver, rz) ).to be_falsy
  end

  it 'is invalid with a non-permissible zip' do
   expect( build(:user, zip: '94118') ).to_not be_valid
  end

  it 'returns driver ride zone' do
    rz = create :ride_zone
    u = create :driver_user, ride_zone: rz
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

  describe 'enqueues email on creation' do
    let(:dummy_mailer) { OpenStruct.new(deliver_later: nil) }

    it 'sends driver email for web registration' do
      expect(UserMailer).to receive(:welcome_email_driver) { dummy_mailer }
      create :driver_user
    end

    it 'does not send email for sms voter' do
      expect(UserMailer).to_not receive(:welcome_email_voter)
      create :sms_voter_user
    end
  end

  describe 'event generation' do
    let(:rz) { create :ride_zone }

    it 'does not send event for new voter' do
      expect(RideZone).to_not receive(:event)
      create :voter_user, ride_zone: rz
    end

    it 'does not send event for updated voter' do
      u = create :voter_user, ride_zone: rz
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
      d = create :driver_user, ride_zone: rz
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

end
