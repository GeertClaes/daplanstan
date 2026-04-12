class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @items = InboxItem
      .joins(trip: { trip_members: :traveler })
      .where(travelers: { user_id: current_user.id })
      .where("review_status = 'pending_review' OR sender_status = 'pending_approval'")
      .includes(:trip)
      .order(received_at: :desc)
  end
end
