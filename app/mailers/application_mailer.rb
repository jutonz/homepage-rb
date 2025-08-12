class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.mail.smtp_user_name
  layout "mailer"
end
