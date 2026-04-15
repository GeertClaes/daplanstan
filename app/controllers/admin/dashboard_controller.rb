class Admin::DashboardController < Admin::ApplicationController
  def index
    @user_count    = User.count
    @trip_count    = Trip.count
    @item_count    = TripItem.count
    @expense_count = Expense.count

    @inbox_pending  = InboxItem.where(review_status: "pending_review").count
    @inbox_total    = InboxItem.count

    @invite_pending = Invite.pending.count
    @invite_used    = Invite.used.count

    @recent_users = User.order(created_at: :desc).limit(10)
    @recent_trips = Trip.order(created_at: :desc).limit(10)
  end
end
