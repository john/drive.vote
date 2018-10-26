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
  it { should validate_length_of(:from_zip).is_at_most(15)}
  it { should validate_length_of(:to_address).is_at_most(100)}
  it { should validate_length_of(:to_city).is_at_most(50)}
  it { should validate_length_of(:to_state).is_at_most(2)}
  it { should validate_length_of(:to_zip).is_at_most(15)}

  describe 'assignable?' do
    it 'returns true if assignable' do
      r = build :waiting_ride
      expect(r.assignable?).to be_truthy
    end

    it 'returns false if not assignable' do
      r = build :complete_ride
      expect(r.assignable?).to be_falsey
    end
  end

  describe 'radius validation' do
    let!(:zone) { create :ride_zone, latitude: 40.409, longitude: -80.09, max_pickup_radius: 5 }

    it 'allows a ride within radius' do
      r = build :waiting_ride, from_address: '106 dunbar avenue', from_city: 'carnegie',
                from_latitude: 40.410, from_longitude: -80.10, ride_zone: zone
      expect(r).to be_valid
      expect(r.errors.count).to eq(0)
    end

    it 'disallows a ride outside radius' do
      r = build :waiting_ride, from_address: '106 dunbar avenue', from_city: 'carnegie',
                from_latitude: 40.6, from_longitude: -80.5, ride_zone: zone
      expect(r).to_not be_valid
      expect(r.errors[:from_address].count).to eq(1)
    end
  end

  describe 'time zone' do
    it 'returns a pickup time that is in correct zone' do
      r = create :ride
      expect(r.pickup_in_time_zone.time_zone).to eq(ActiveSupport::TimeZone.new(r.ride_zone.time_zone))
    end
  end

  it 'finds completed rides' do
    complete = create :complete_ride
    canceled = create :canceled_ride
    sched = create :scheduled_ride
    expect(Ride.completed.count).to eq(2)
  end

  describe 'status string' do
    it 'returns N/A' do
      expect(Ride.new.status_str).to eq('N/A')
    end

    it 'titleizes' do
      expect(Ride.new(status: 'waiting_assignment').status_str).to eq('Waiting Assignment')
    end
  end

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
      allow_any_instance_of(Conversation).to receive(:notify_voter_of_assignment)
      r = create :ride, driver: driver, conversation: convo, ride_zone: convo.ride_zone
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).with(anything, :driver_changed, anything, :driver)
      r.update_attribute(:status, :picked_up)
    end

    it 'sends driver update event on driver clear' do
      allow_any_instance_of(Conversation).to receive(:notify_voter_of_assignment)
      r = create :ride, driver: driver, conversation: convo, status: :driver_assigned
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).with(anything, :driver_changed, anything, :driver)
      expect_any_instance_of(Conversation).to receive(:notify_voter_of_assignment).with(nil)
      r.clear_driver
    end

    it 'sends driver update event on driver assignment' do
      r = create :ride, conversation: convo
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).with(anything, :driver_changed, anything, :driver)
      expect_any_instance_of(Conversation).to receive(:notify_voter_of_assignment)
      r.assign_driver(driver)
    end

    it 'sends driver update event on driver reassignment' do
      allow_any_instance_of(Conversation).to receive(:notify_voter_of_assignment)
      r = create :ride, conversation: convo, driver: driver, status: 'driver_assigned'
      expect(RideZone).to receive(:event).with(anything, :conversation_changed, anything)
      expect(RideZone).to receive(:event).twice.with(anything, :driver_changed, anything, :driver)
      expect_any_instance_of(Conversation).to receive(:notify_voter_of_assignment)
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

    it 'assigns driver as needing acceptance' do
      expect(ride.assign_driver(driver, false, true)).to be_truthy
      expect(ride.reload.driver_id).to eq(driver.id)
      expect(ride.status).to eq('waiting_acceptance')
    end

    it 'sends voter a text on driver assignment' do
      convo = create :complete_conversation
      ride = Ride.create_from_conversation(convo)
      expect_any_instance_of(Conversation).to receive(:notify_voter_of_assignment)
      ride.assign_driver(driver, false, false)
    end

    it 'does not send voter a text on driver waiting_acceptance' do
      convo = create :complete_conversation
      ride = Ride.create_from_conversation(convo)
      expect_any_instance_of(Conversation).to_not receive(:notify_voter_of_assignment)
      ride.assign_driver(driver, false, true)
    end

    it 'does not send voter a text on driver canceling waiting_acceptance' do
      convo = create :complete_conversation
      ride = Ride.create_from_conversation(convo)
      ride.assign_driver(driver, false, true)
      expect_any_instance_of(Conversation).to_not receive(:notify_voter_of_assignment)
      ride.clear_driver(driver)
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

  describe 'cancel' do
    let(:convo) { create :complete_conversation }
    let(:driver) { create :driver_user, rz: convo.ride_zone }
    let(:ride) { r = Ride.create_from_conversation(convo); r.assign_driver(driver); r}

    it 'cancels' do
      ride.cancel('foo')
      expect(ride.reload.status).to eq('canceled')
      expect(ride.driver).to be_nil
      expect(ride.description =~ /foo/).to be_truthy
      expect(convo.reload.status).to eq('closed')
    end
  end

  describe 'waiting nearby' do
    let!(:zone) { create :ride_zone, latitude: 35, longitude: -122, max_pickup_radius: 50 }
    let!(:other_zone) { create :ride_zone, latitude: 35, longitude: -122 }
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

    it 'returns distance' do
      rides = Ride.waiting_nearby(zone.id, 35, -122, 3, 100)
      expect(rides[0].distance_to_voter).to_not be_nil
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
    ride.update_attributes(status: :complete)
    expect(c.reload.status).to eq('closed')
  end

  it 'updates conversation to closed when ride canceled' do
    c = create :conversation_with_messages
    ride = create :ride, conversation: c
    ride.update_attributes(status: :canceled)
    expect(c.reload.status).to eq('closed')
  end

  it 'does not send text when ride canceled' do
    expect_any_instance_of(Conversation).to_not receive(:notify_voter_of_assignment)
    c = create :conversation_with_messages
    ride = create :ride, conversation: c
    ride.cancel('foobar')
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

  describe 'confirming scheduled rides' do
    it 'confirms only scheduled rides that are soon' do
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 10)
      c1 = create :complete_conversation, pickup_at: 20.minutes.from_now, status: :help_needed
      c2 = create :complete_conversation, pickup_at: 20.minutes.from_now
      c3 = create :complete_conversation, pickup_at: 40.minutes.from_now
      Ride.create_from_conversation(c1)
      Ride.create_from_conversation(c2).update_attribute(:status, :waiting_assignment)
      Ride.create_from_conversation(c3)
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 30) # only c1 should now match
      expect_any_instance_of(Conversation).to receive(:attempt_confirmation).once
      Ride.confirm_scheduled_rides
      expect(c1.reload.status).to eq('ride_created')
    end

    it 'handles conversations with missing user' do
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 10)
      c1 = create :complete_conversation, pickup_at: 20.minutes.from_now
      Ride.create_from_conversation(c1)
      User.find(c1.user.id).delete # no callbacks
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 30)
      expect(Conversation).to_not receive(:send_staff_sms)
      Ride.confirm_scheduled_rides
    end

    it 'does not attempt if no ride zone' do
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 10)
      c1 = create :complete_conversation, pickup_at: 20.minutes.from_now
      r = Ride.create_from_conversation(c1)
      r.ride_zone = nil; r.save
      stub_const('Ride::SWITCH_TO_WAITING_ASSIGNMENT', 30)
      expect(Conversation).to_not receive(:send_staff_sms)
      Ride.confirm_scheduled_rides
    end
  end

  it 'produces safe api text' do
    r = create :ride, driver: (create :user, name: '&')
    expect(r.api_json['driver_name']).to eq('&amp;')
  end
  
  it 'can be created from a potential_ride' do
    user = create :user
    potential_ride = create :potential_ride
    ride = Ride.create_from_potential_ride( potential_ride, user )
    expect(ride).to be_a Ride
    expect(potential_ride.status).to eq("converted")
  end
end
