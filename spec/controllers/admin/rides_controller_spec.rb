require 'rails_helper'

RSpec.describe Admin::RidesController, type: :controller do
  login_admin

  # This should return the minimal set of attributes required to create a valid
  # Ride. As you add validations to Ride, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {voter_id: 1, name: 'foo', description: 'bar'}
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET #index" do
    it "assigns all rides as @rides" do
      ride = create :ride
      get :index, params: {}
      expect(assigns(:rides)).to eq([ride])
    end
  end

end
