class UserMailer < ApplicationMailer
  include SendGrid

  layout 'mailer'

  sendgrid_enable   :ganalytics, :opentrack, :clicktrack
  default from: 'hello@drive.vote'

  # Use the previewer to check emails:
  # http://local.drive.vote:3000/rails/mailers/user_mailer/welcome_email_not_inlined
  # http://local.drive.vote:3000/rails/mailers/user_mailer/welcome_email
  #
  # Get it right using welcome_email_not_inlined, then take the contents of that
  # template, and inline the CSS. Remeber to just delete the styles in the header
  # once they've been inlined:

  # http://templates.mailchimp.com/resources/inline-css/

  def welcome_email_driver(user, ride_zone=nil)
    sendgrid_category "welcome_driver"
    @user = user
    @ride_zone = ride_zone

    mail(to: @user.email_with_name, subject: 'Thank you for volunteering to Drive the Vote!')
  end

  def welcome_email_voter(user)
    sendgrid_category "welcome_voter"
    @user = user

    mail(to: @user.email_with_name, subject: 'Welcome to Drive the Vote, Voter!')
  end

  def welcome_email_voter_ride(user, ride)
    sendgrid_category "welcome_voter_ride"
    @user = user
    @ride = ride
    mail(to: @user.email_with_name, subject: 'Welcome to Drive the Vote!')
  end

  def welcome_email_not_inlined(user)
    sendgrid_category "welcome_not_inlined"
    @user = user

    mail(to: @user.email_with_name, subject: 'Welcome to Drive the Vote!')
  end
end
