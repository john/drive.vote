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
    ride = Ride.new(pickup_at: Time.now, from_address: "330 Cabrillo St.", from_city: "Tampa, FL")
    UserMailer.welcome_email_voter_ride(user, ride)
  end

end