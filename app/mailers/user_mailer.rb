class UserMailer < ApplicationMailer
  include SendGrid
  
  sendgrid_enable   :ganalytics, :opentrack, :clicktrack
    
  default from: 'john@drive.vote'
 
    def welcome_email(user)
      sendgrid_category "Welcome"
      @user = user
      @url  = 'http://example.com/login'
      
      email_with_name = %("#{@user.name}" <#{@user.email}>)
      mail(to: email_with_name, subject: 'Welcome to Drive the Vote!')
    end
    
end
