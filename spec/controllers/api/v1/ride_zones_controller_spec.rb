require 'rails_helper'

RSpec.describe Api::V1::RideZonesController, :type => :controller do
  describe 'conversations' do
    let!(:notinrz) { create :conversation }
    let(:rz) { create :ride_zone }
    let!(:c1) { create :conversation, ride_zone: rz, status: :in_progress }
    let!(:c2) { create :conversation, ride_zone: rz, status: :ride_created }
    let!(:c3) { create :conversation, ride_zone: rz, status: :closed }

    it 'is successful' do
      get :conversations, params: {id: rz.id}
      expect(response).to be_successful
    end

    it 'returns active conversations' do
      get :conversations, params: {id: rz.id}
      expect(JSON.parse(response.body)['response']).to match_array([c1.api_json(true), c2.api_json(true)])
    end

    it 'returns requested conversations' do
      get :conversations, params: {id: rz.id, status: :ride_created}
      expect(JSON.parse(response.body)['response']).to match_array([c2.api_json(true)])
    end

    it 'returns multitype requested conversations' do
      get :conversations, params: {id: rz.id, status: 'ride_created, closed'}
      expect(JSON.parse(response.body)['response']).to match_array([c2.api_json(true), c3.api_json(true)])
    end

    it '404s for missing ride zone' do
      get :conversations, params: {id: 0}
      expect(response.status).to eq(404)
    end
  end

  describe 'create conversation' do
    let(:rz) { create :ride_zone }
    let(:user) { create :driver_user, ride_zone: rz }
    let(:body) { 'can you go to south side?' }
    let(:convo) { create :conversation }

    before :each do
      allow(Conversation).to receive(:create_from_staff).and_return(convo)
    end

    it 'is successful' do
      post :create_conversation, params: {id: rz.id, user_id: user.id, body: body}
      expect(response).to be_successful
    end

    it 'calls conversation model and responds with json' do
      expect(Conversation).to receive(:create_from_staff).and_return(convo)
      post :create_conversation, params: {id: rz.id, user_id: user.id, body: body}
      expect(JSON.parse(response.body)['response']).to eq(convo.api_json)
    end

    it 'handles error from conversation' do
      expect(Conversation).to receive(:create_from_staff).and_return('error')
      post :create_conversation, params: {id: rz.id, user_id: user.id, body: body}
      expect(response.status).to eq(408)
      expect(JSON.parse(response.body)['error']).to eq('error')
    end

    it 'validates user id' do
      post :create_conversation, params: {id: rz.id, user_id: 0}
      expect(response.status).to eq(404)
    end

    it '404s for missing ride zone' do
      get :create_conversation, params: {id: 0}
      expect(response.status).to eq(404)
    end
  end

  describe 'drivers' do
    let!(:rz) { create :ride_zone }
    let!(:u1) { create :driver_user, ride_zone: rz }
    let!(:u2) { create :driver_user, ride_zone: rz }
    let!(:ride) { create :ride, ride_zone: rz }
    let(:rz2) { create :ride_zone }
    let!(:notinrz) { create :driver_user, ride_zone: rz2 }

    it 'is successful' do
      get :drivers, params: {id: rz.id}
      expect(response).to be_successful
    end

    it 'returns drivers for ride zone' do
      get :drivers, params: {id: rz.id}
      resp = JSON.parse(response.body)['response']
      expect(resp).to match_array([u1.api_json.as_json, u2.api_json.as_json])
    end

    it 'succeeds assigning rides to drivers' do
      post :assign_ride, params: {id: rz.id, driver_id: u1.id, ride_id: ride.id}
      expect(response).to be_successful
    end

    it 'assigns the ride to driver' do
      post :assign_ride, params: {id: rz.id, driver_id: u1.id, ride_id: ride.id}
      expect(u1.reload.active_ride).to_not be_nil
    end

    it 'removes if already assigned' do
      ride.assign_driver(u2)
      post :assign_ride, params: {id: rz.id, driver_id: u1.id, ride_id: ride.id}
      expect(response).to be_successful
      expect(ride.reload.driver).to eq(u1)
    end

    it '404s for missing ride zone' do
      get :drivers, params: {id: 0}
      expect(response.status).to eq(404)
    end

    it '404s for missing driver' do
      post :assign_ride, params: {id: rz.id, driver_id: 0, ride_id: ride.id}
      expect(response.status).to eq(404)
    end

    it '404s for missing ride' do
      post :assign_ride, params: {id: rz.id, driver_id: u1.id, ride_id: 0}
      expect(response.status).to eq(404)
    end
  end

  describe 'rides' do
    let!(:rz) { create :ride_zone }
    let!(:r_incomplete) { create :ride, ride_zone: rz }
    let!(:r_waiting) { create :waiting_ride, ride_zone: rz }
    let!(:r_assigned) { create :assigned_ride, ride_zone: rz }
    let!(:r_picked_up) { create :picked_up_ride, ride_zone: rz }
    let!(:r_complete) { create :complete_ride, ride_zone: rz }
    let!(:r_soon) { create :scheduled_ride, ride_zone: rz, pickup_at: 5.minutes.from_now }
    let!(:r_later) { create :scheduled_ride, ride_zone: rz, pickup_at: 90.minutes.from_now }
    let(:rz2) { create :ride_zone }
    let!(:notinrz) { create :waiting_ride, ride_zone: rz2 }

    it 'is successful' do
      get :rides, params: {id: rz.id}
      expect(response).to be_successful
    end

    it 'returns rides for ride zone' do
      get :rides, params: {id: rz.id}
      resp = JSON.parse(response.body)['response']
      expect(resp).to match_array([r_waiting.api_json.as_json, r_assigned.api_json.as_json,
                                   r_picked_up.api_json.as_json, r_soon.api_json.as_json])
    end

    it 'returns multitype requested conversations' do
      get :rides, params: {id: rz.id, status: 'driver_assigned, picked_up'}
      resp = JSON.parse(response.body)['response']
      expect(resp).to match_array([r_assigned.api_json, r_picked_up.api_json])
    end

    it '404s for missing ride zone' do
      get :rides, params: {id: 0}
      expect(response.status).to eq(404)
    end
  end

  describe 'create ride' do
    let!(:rz) { create :ride_zone }
    let!(:voter) { create :voter_user }

    it 'is successful' do
      post :create_ride, params: {id: rz.id, ride: { voter_id: voter.id, name: 'foo'} }
      expect(response).to be_successful
    end

    it 'creates a new ride for the ride zone' do
      expect {
          post :create_ride, params: {id: rz.id, ride: { voter_id: voter.id, name: 'foo'} }
      }.to change(Ride, :count).by(1)
      expect(Ride.first.name).to eq('foo')
    end

    it 'does not create a ride with missing voter_id' do
      expect {
          post :create_ride, params: {id: rz.id, ride: { name: 'foo' } }
      }.to change(Ride, :count).by(0)
      expect(JSON.parse(response.body)['error']).to include('voter')
    end
  end

  describe 'update ride zone', focus: true do
    let(:rz) { create :ride_zone }
    let(:rz_updates) {
      {
         name: 'beebee',
         description: 'baba',
         phone_number: 'bobo',
         short_code: 'bibi',
         city: 'bubu',
         county: 'byby',
         state: 'boiboi',
         zip: 'blahblah',
         country: 'behbeh',
         latitude: 1.234,
         longitude: 3.423,
         slug: 'slug_slug',
         bot_disabled: !rz.bot_disabled
      }.stringify_keys
    }

    it 'anonymous user cannot enable and disable bot' do
      expect {
        put :update, params: { id: rz.id, ride_zone: { bot_disabled: true } }
      }.to_not change{ RideZone.find(rz.id).bot_disabled }.from(false)
    end

    context 'user' do
      login_user
      it 'cannot enable and disable bot' do
        expect {
          put :update, params: { id: rz.id, ride_zone: { bot_disabled: true } }
        }.to_not change{ RideZone.find(rz.id).bot_disabled }.from(false)
      end
    end

    context 'dispatcher' do
      login_dispatcher
      it 'can enable and disable bot' do
        # Disable
        expect {
          put :update, params: { id: rz.id, ride_zone: { bot_disabled: true } }
          expect(JSON.parse(response.body)['bot_disabled']).to be true
        }.to change{ RideZone.find(rz.id).bot_disabled }.from(false).to(true)

        # No change no-ops.
        expect {
          put :update, params: { id: rz.id, ride_zone: { bot_disabled: true } }
          expect(JSON.parse(response.body)['bot_disabled']).to be true
        }.to_not change{ RideZone.find(rz.id).bot_disabled }.from(true)

        # Enable
        expect {
          put :update, params: { id: rz.id, ride_zone: { bot_disabled: false } }
          expect(JSON.parse(response.body)['bot_disabled']).to be false
        }.to change{ RideZone.find(rz.id).bot_disabled }.from(true).to(false)
      end

      it 'cannot update fields other than bot disabled' do
        put :update, params: { id: rz.id, ride_zone: rz_updates }
        response_rz = JSON.parse(response.body)

        expect(response_rz).to_not include(rz_updates.except('bot_disabled'))
        expect(response_rz['bot_disabled']).to eql(rz_updates['bot_disabled'])

        stored_rz = RideZone.find(rz.id).as_json
        expect(stored_rz).to_not include(rz_updates.except('bot_disabled'))
        expect(stored_rz['bot_disabled']).to eql(rz_updates['bot_disabled'])
      end
    end

    context 'admin' do
      login_admin
      it 'can update all fields' do
        put :update, params: { id: rz.id, ride_zone: rz_updates }
        response_rz = JSON.parse(response.body)

        # Correctly convert the non-string types so rspec include can match.
        response_rz['latitude'] = response_rz['latitude'].to_d if response_rz.key?('latitude')
        response_rz['longitude'] = response_rz['longitude'].to_d if response_rz.key?('latitude')

        expect(response_rz).to include(rz_updates)

        expect(RideZone.find(rz.id).as_json).to include(rz_updates)
      end
    end
  end
end
