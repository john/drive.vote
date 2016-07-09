class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    user = User.first
    UserMailer.welcome_email(user)
  end
  
  def welcome_email
    user = User.first
    UserMailer.welcome_email(user)
  end
  
  def welcome_email_not_inlined
    user = User.first
    UserMailer.welcome_email_not_inlined(user)
  end

end