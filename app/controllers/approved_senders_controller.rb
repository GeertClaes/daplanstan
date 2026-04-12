class ApprovedSendersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def create
    inbox_item = @trip.inbox_items.find(params[:inbox_item_id]) if params[:inbox_item_id]

    @trip.approved_senders.create!(
      email:       params[:email],
      approved_by: current_user,
      approved_at: Time.current
    )

    if inbox_item
      inbox_item.update!(sender_status: :approved)
      ParseInboxItemJob.perform_later(inbox_item.id)
    end

    redirect_to trip_inbox_items_path(@trip), notice: "Sender approved."
  end

  def destroy
    sender = @trip.approved_senders.find(params[:id])
    sender.destroy
    redirect_to trip_path(@trip), notice: "Sender removed."
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:trip_id])
  end
end
