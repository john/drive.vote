namespace :rides do
  desc 'Confirm upcoming scheduled rides'
  task :confirm_scheduled_rides => :environment do
    Ride.confirm_scheduled_rides
  end
end

