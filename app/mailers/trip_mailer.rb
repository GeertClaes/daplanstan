class TripMailer < ApplicationMailer
  def pending_sender_notification(trip_member, inbox_item)
    @trip      = trip_member.trip
    @inbox_item = inbox_item

    mail(
      to:      trip_member.traveler.display_email,
      subject: "New email from unknown sender on \"#{@trip.title}\""
    )
  end
end
