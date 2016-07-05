class UserMailerPreview < ActionMailer::Preview

  def welcome_email
    user = User.first
    UserMailer.welcome_email(user)
  end

end