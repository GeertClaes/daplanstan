class ApplicationMailer < ActionMailer::Base
  default from:     ENV.fetch("POSTMARK_FROM_EMAIL", "noreply@daplanstan.com"),
          reply_to: ENV.fetch("POSTMARK_REPLY_TO", "hello@daplanstan.com")
  layout "mailer"
end
