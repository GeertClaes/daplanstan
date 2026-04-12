class TripMailbox < ActionMailbox::Base
  def process
    to_address = mail.to&.first.to_s.downcase.strip
    trip = Trip.find_by(inbound_email: to_address)

    unless trip
      Rails.logger.warn "[TripMailbox] No trip found for inbound address: #{to_address}"
      return
    end

    from_email = mail.from&.first.to_s.downcase.strip
    approved   = trip.approved_senders.exists?(email: from_email) ||
                 trip.trip_members.joins(:traveler).where(travelers: { email: from_email }).exists? ||
                 trip.trip_members.joins(traveler: :user).where(users: { email: from_email }).exists?

    inbox_item = trip.inbox_items.create!(
      from_email:    from_email,
      from_name:     mail.from_address&.display_name.presence,
      subject:       mail.subject.presence || "(no subject)",
      raw_body:      extract_text_body,
      raw_html:      extract_html_body,
      received_at:   mail.date || Time.current,
      sender_status: approved ? :approved : :pending_approval
    )

    if approved
      ParseInboxItemJob.perform_later(inbox_item.id)
    else
      notify_owners_of_pending_sender(trip, inbox_item)
    end
  end

  private

  def extract_text_body
    if mail.multipart?
      mail.text_part&.decoded.presence || mail.decoded
    else
      mail.decoded
    end
  rescue StandardError
    mail.body.to_s
  end

  def extract_html_body
    if mail.multipart?
      mail.html_part&.decoded.presence
    elsif mail.content_type&.include?("text/html")
      mail.decoded
    end
  rescue StandardError
    nil
  end

  def notify_owners_of_pending_sender(trip, inbox_item)
    Rails.logger.info "[TripMailbox] Pending approval for #{inbox_item.from_email} on trip #{trip.id}"
    trip.trip_members.where(role: :owner).includes(:traveler).each do |member|
      TripMailer.pending_sender_notification(member, inbox_item).deliver_later
    end
  end
end
