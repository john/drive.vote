require "rails_helper"

# https://relishapp.com/rspec/rspec-rails/docs/mailer-specs
RSpec.describe UserMailer, :type => :mailer do
  
  describe "notify_scheduled_ride" do
    let(:rz) { create :ride_zone }
    let(:voter) { create :voter }
    let(:ride) { create :ride, ride_zone: rz, voter: voter }
    
    it "renders the headers" do
      mail = UserMailer.notify_scheduled_ride(ride)
      expect(mail.subject).to eq("Your ride to the polls is coming soon")
    end

  end
  
end
