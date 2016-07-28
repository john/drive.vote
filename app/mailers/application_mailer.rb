class ApplicationMailer < ActionMailer::Base
  default from: 'john@drive.vote'
  layout 'mailer'
end
