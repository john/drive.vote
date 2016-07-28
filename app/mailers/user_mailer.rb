class UserMailer < ApplicationMailer
  include SendGrid

  sendgrid_enable   :ganalytics, :opentrack, :clicktrack    
  default from: 'john@drive.vote'

  # Use the previewer to check emails:
  # http://local.drive.vote:3000/rails/mailers/user_mailer/welcome_email_not_inlined
  # http://local.drive.vote:3000/rails/mailers/user_mailer/welcome_email
  #
  # Get it right using welcome_email_not_inlined, then take the contents of that
  # template, and inline the CSS. Remeber to just delete the styles in the header
  # once they've been inlined:
  
  # http://templates.mailchimp.com/resources/inline-css/

  def welcome_email(user)
    sendgrid_category "Welcome"
    @user = user
    @url  = 'http://example.com/login'

    email_with_name = %("#{@user.name}" <#{@user.email}>)
    mail(to: email_with_name, subject: 'Welcome to Drive the Vote!')
  end


  def welcome_email_not_inlined(user)
    sendgrid_category "Welcome"
    @user = user
    # @url  = 'http://example.com/login'

    email_with_name = %("#{@user.name}" <#{@user.email}>)
    mail(to: email_with_name, subject: 'Welcome to Drive the Vote!')
  end

end
