require 'rails_helper'

RSpec.describe RideUpload, type: :model do
  it { should belong_to(:ride_zone) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:ride_zone) }
  it { should validate_presence_of(:status) }
  
  describe 'Factory' do
    
    it 'has an attachment' do
      expect(create(:ride_upload_with_csv).csv).to be_attached
    end
    
    it 'is valid' do
      expect(create(:ride_upload_with_csv)).to be_valid
    end

    context "not a csv" do
      let(:ride_upload_with_non_csv) { build :ride_upload_with_non_csv }
      
      it 'must be a csv' do
        ride_upload_with_non_csv.valid?
        expect( ride_upload_with_non_csv.errors[:csv]).to include('Must be a CSV file')
      end
    end
  end
  
  # https://medium.com/craft-academy/rails-attachments-with-active-storage-e8c9e726ab0d
end
