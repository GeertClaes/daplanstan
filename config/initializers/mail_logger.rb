module MailLogger
  def self.delivered_email(message)
    Rails.logger.info "[Mailer] Sent '#{message.subject}' to #{Array(message.to).join(', ')}"
  end
end

ActionMailer::Base.register_observer(MailLogger)

# Log and swallow delivery errors in jobs so one bad email doesn't crash the job.
# The error is still visible in the Rails log and Solid Queue's job failure record.
ActionMailer::Base.rescue_from(StandardError) do |error|
  Rails.logger.error "[Mailer] Delivery failed: #{error.class}: #{error.message}"
  Rails.logger.error error.backtrace.first(5).join("\n") if error.backtrace
end
