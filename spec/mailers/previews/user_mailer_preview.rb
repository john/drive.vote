class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    user = User.first
    UserMailer.welcome_email(user)
  end

  def welcome_email_not_inlined
    user = User.first
    UserMailer.welcome_email_not_inlined(user)
  end

  def welcome_email_voter_ride
    user = User.first
    rz = RideZone.create(name: 'Tampa', slug: 'tampa')
    ride = Ride.new(voter_id: user.id, ride_zone_id: rz.id, pickup_at: Time.now, from_address: "330 Cabrillo St.", from_city: "Tampa, FL")

    UserMailer.welcome_email_voter_ride(user, ride)
  end

  def welcome_email_driver
    user = User.first
    UserMailer.welcome_email_driver(user)
  end

  def welcome_email_driver_rz
    user = User.first
    rz = RideZone.create(name: 'Tampa', slug: 'tampa')
    UserMailer.welcome_email_driver(user, rz)
  end

end