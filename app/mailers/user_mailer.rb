class UserMailer < ApplicationMailer

  layout 'mailer'

  default from: 'hello@drive.vote'

  # Use the previewer to check emails:
  # http://local.drive.vote:3000/rails/mailers/user_mailer/welcome_email_not_inlined
  # http://local.drive.vote:3000/rails/mailers/user_mailer/welcome_email
  #
  # Get it right using welcome_email_not_inlined, then take the contents of that
  # template, and inline the CSS. Remeber to just delete the styles in the header
  # once they've been inlined:

  # http://templates.mailchimp.com/resources/inline-css/
  
  def notify_driver_approved(user, ride_zone)
    @user = user
    @ride_zone = ride_zone

    mail(to: @user.email_with_name, subject: 'You\'re approved to drive')
  end

  def notify_scheduled_ride(ride)
    @ride = ride
    @user = ride.voter

    mail(to: @user.email_with_name, subject: 'Your ride to the polls is coming soon')
  end

  def welcome_email_driver(user, ride_zone=nil)
    @user = user
    @ride_zone = ride_zone

    mail(to: @user.email_with_name, subject: 'Thank you for volunteering to Drive the Vote!')
  end

  def welcome_email_voter_ride(user, ride)
    @user = user
    @ride = ride
    mail(to: @user.email_with_name, subject: 'Welcome to Drive the Vote!')
  end

  def welcome_email_not_inlined(user)
    @user = user

    mail(to: @user.email_with_name, subject: 'Welcome to Drive the Vote!')
  end
end
