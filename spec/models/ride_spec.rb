require 'rails_helper'

RSpec.describe Ride, type: :model do
  it_behaves_like 'to_from_addressable'

  it { should belong_to(:ride_zone) }
  it { should belong_to(:voter) }
  it { should validate_presence_of(:voter) }
  it { should validate_length_of(:name).is_at_most(50)}

  it { should validate_length_of(:from_address).is_at_most(100)}
  it { should validate_length_of(:from_city).is_at_most(50)}
  it { should validate_length_of(:from_state).is_at_most(2)}
  it { should validate_length_of(:from_zip).is_at_most(50)}
  it { should validate_length_of(:to_address).is_at_most(100)}
  it { should validate_length_of(:to_city).is_at_most(50)}
  it { should validate_length_of(:to_state).is_at_most(2)}
  it { should validate_length_of(:to_zip).is_at_most(12)}

  describe 'event generation' do
    let!(:driver) { create :driver_user }
    let!(:new_driver) { create :driver_user }
    let!(:convo) { create :conversation_with_messages }

    it 'sends conversation event on new ride' do
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      create :ride, conversation: convo, ride_zone: convo.ride_zone
    end

    it 'sends conversation update event but not driver' do
      r = create :ride, conversation: convo
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to_not receive(:event).with(anything, :driver_changed, anything)
      r.update_attribute(:pickup_at, Time.now)
    end

    it 'sends driver update event on status change' do
      r = create :ride, driver: driver, conversation: convo, ride_zone: convo.ride_zone
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).with(anything, :driver_changed, anything, :driver)
      r.update_attribute(:status, :picked_up)
    end

    it 'sends driver update event on driver clear' do
      r = create :ride, driver: driver, conversation: convo
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).with(anything, :driver_changed, anything, :driver)
      r.clear_driver
    end

    it 'sends driver update event on driver assignment' do
      r = create :ride, conversation: convo
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).with(anything, :driver_changed, anything, :driver)
      r.assign_driver(driver)
    end

    it 'sends driver update event on driver reassignment' do
      r = create :ride, conversation: convo, driver: driver
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).twice.with(anything, :driver_changed, anything, :driver)
      r.reassign_driver(new_driver)
    end
  end

  describe 'driver functions' do
    let(:rz) { create :ride_zone }
    let(:ride) { create :ride, ride_zone: rz }
    let(:driver) { u = create :user; u.add_role(:driver, rz); u }
    let(:driver2) { u = create :user; u.add_role(:driver, rz); u }

    it 'assigns driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.driver_id).to eq(driver.id)
      expect(ride.status).to eq('driver_assigned')
    end

    it 'does not assign driver if already has one' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.assign_driver(driver2)).to be_falsey
      expect(ride.reload.driver_id).to eq(driver.id)
      expect(ride.status).to eq('driver_assigned')
    end

    it 'allows reassign driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.reassign_driver(driver2)).to be_truthy
      expect(ride.reload.driver_id).to eq(driver2.id)
    end

    it 'clears driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.clear_driver(driver)).to be_truthy
      expect(ride.reload.driver_id).to  be_nil
      expect(ride.status).to eq('waiting_assignment')
    end

    it 'does not clear different driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.clear_driver(driver2)).to be_falsey
      expect(ride.reload.driver_id).to  eq(driver.id)
      expect(ride.status).to eq('driver_assigned')
    end

    it 'picks up by driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.pickup_by(driver)).to be_truthy
      expect(ride.reload.status).to eq('picked_up')
    end

    it 'does not pick up with different driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.pickup_by(driver2)).to be_falsey
      expect(ride.reload.status).to eq('driver_assigned')
    end

    it 'completes up by driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.complete_by(driver)).to be_truthy
      expect(ride.reload.status).to eq('complete')
    end

    it 'does not complete with different driver' do
      expect(ride.assign_driver(driver)).to be_truthy
      expect(ride.reload.complete_by(driver2)).to be_falsey
      expect(ride.reload.status).to eq('driver_assigned')
    end
  end

  describe 'waiting nearby' do
    let!(:zone) { create :ride_zone }
    let!(:other_zone) { create :ride_zone }
    let!(:empty_zone) { create :ride_zone }
    let!(:rnotwaiting) { create :ride, from_latitude: 35, from_longitude: -122, ride_zone: zone }
    let!(:rotherzone) { create :waiting_ride, from_latitude: 35, from_longitude: -122, ride_zone: other_zone }
    let!(:r1) { create :waiting_ride, from_latitude: 35.1, from_longitude: -122.1, ride_zone: zone }
    let!(:r2) { create :waiting_ride, from_latitude: 35.5, from_longitude: -122.4, ride_zone: zone }
    let!(:r3) { create :waiting_ride, from_latitude: 35.2, from_longitude: -122.2, ride_zone: zone }
    let!(:r4) { create :waiting_ride, from_latitude: 35.3, from_longitude: -122.3, ride_zone: zone }

    it 'returns empty if no waiting rides' do
      expect(Ride.waiting_nearby(empty_zone.id, 35, -122, 10, 100)).to  eq([])
    end

    it 'returns ordered set of rides with limit' do
      expect(Ride.waiting_nearby(zone.id, 35, -122, 3, 100)).to eq([r1, r3, r4])
    end

    it 'checks radius' do
      expect(Ride.waiting_nearby(zone.id, 35, -122, 3, 0.1)).to eq([])
    end
  end

  context 'passengers' do
    describe 'passenger_count' do
      let(:rz) { create :ride_zone }
      let(:ride) { create :ride, ride_zone: rz }

      it 'should return a count, inclusive of Voter as passenger' do
        # no additional passengers
        expect(ride.passenger_count).to eq(1)

        # one additional passenger
        ride.additional_passengers = 1
        expect(ride.passenger_count).to eq(2)

        # two additional passenger
        ride.additional_passengers = 2
        expect(ride.passenger_count).to eq(3)
      end
    end
  end

  it 'reports active' do
    expect(create(:ride, status: :driver_assigned)).to be_active
    expect(create(:ride, status: :scheduled)).to_not be_active
  end

  it 'reports unknown destination' do
    expect(create(:ride, to_address: Ride::UNKNOWN_ADDRESS).has_unknown_destination?).to be_truthy
  end

  it 'updates conversation to closed when ride complete' do
    c = create :conversation_with_messages
    ride = create :ride, conversation: c
    ride.update_attribute(:status, :complete)
    expect(c.reload.status).to eq('closed')
  end

  it 'updates status timestamp on create' do
    r = create :ride
    expect(r.reload.status_updated_at).to_not be_nil
  end

  it 'switches scheduled to waiting_assignment on create' do
    r = create :ride, status: :scheduled, pickup_at: Time.now
    expect(r.reload.status).to eq('waiting_assignment')
  end

  it 'keeps scheduled for future time' do
    r = create :ride, status: :scheduled, pickup_at: (2*Ride::SWITCH_TO_WAITING_ASSIGNMENT).minutes.from_now
    expect(r.reload.status).to eq('scheduled')
  end

  it 'updates status timestamp on status change' do
    r = Timecop.travel(1.hour.ago) do
      create :ride
    end
    r.update_attribute(:status, :complete)
    expect(Time.now - r.reload.status_updated_at).to be <(10)
  end

  describe 'confirming scheduled rides', focus:true do
    it 'confirms only scheduled rides that are soon' do
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 10)
      c1 = create :complete_conversation, pickup_time: 20.minutes.from_now
      c2 = create :complete_conversation, pickup_time: 20.minutes.from_now
      c3 = create :complete_conversation, pickup_time: 40.minutes.from_now
      Ride.create_from_conversation(c1)
      Ride.create_from_conversation(c2).update_attribute(:status, :waiting_assignment)
      Ride.create_from_conversation(c3)
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 30) # only c1 should now match
      expect_any_instance_of(Conversation).to receive(:attempt_confirmation).once
      Ride.confirm_scheduled_rides
    end
  end
end
