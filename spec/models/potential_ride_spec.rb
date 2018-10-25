require 'rails_helper'

RSpec.describe PotentialRide, type: :model do
  it { should belong_to(:ride_zone) }
  it { should belong_to(:voter) }
  it { should belong_to(:ride_upload) }
  it { should validate_presence_of(:ride_zone) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:pickup_at) }
  it { should validate_presence_of(:from_address) }
  it { should validate_presence_of(:from_city) }
  it { should validate_presence_of(:status) }
  
  describe 'potential rides' do
    let(:potential_ride) { create :potential_ride }
    
    it "populates notes from fail_because" do
      potential_ride.fail_because("This is the reason it failed");
      expect(potential_ride.notes).to eq("This is the reason it failed")
    end
    
    it "populates a potential ride from a CSV row" do
      # include this to get fixture_file_upload
      extend ActionDispatch::TestProcess
    
      test_csv = fixture_file_upload( Rails.root.join('spec', 'factories', 'files', 'test_ride_upload_valid.csv'), 'text/csv' )
      :ride_upload_with_csv
      CSV.foreach( test_csv, headers: true ) do |row|
        potential_ride_from_first_row = potential_ride.populate_from_csv_row(row)
        expect(potential_ride_from_first_row.name).to eq("Testy McTesterson")
        break
      end
    end
  end
end
