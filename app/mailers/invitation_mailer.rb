class InvitationMailer < ApplicationMailer
  def invite(inviter, email)
    @inviter = inviter
    @sign_in_url = root_url
    mail(to: email, subject: "#{inviter.name} invited you to DaPlanStan")
  end

  def invite_to_trip(inviter, email, trip)
    @inviter = inviter
    @trip = trip
    @sign_in_url = root_url
    mail(to: email, subject: "#{inviter.name} invited you to join '#{trip.title}' on DaPlanStan")
  end
end
