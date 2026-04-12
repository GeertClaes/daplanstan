class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :current_account, :current_member_for, :pending_inbox_count, :pending_inbox_path

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_account
    @current_account ||= current_user&.account
  end

  def current_member_for(trip)
    return nil unless current_user
    trip.trip_members.joins(:traveler).find_by(travelers: { user_id: current_user.id })
  end

  def pending_inbox_count
    pending_inbox_items.count
  end

  def pending_inbox_path
    notifications_path
  end

  def pending_inbox_items
    return InboxItem.none unless current_user
    @pending_inbox_items ||= InboxItem
      .joins(trip: { trip_members: :traveler })
      .where(travelers: { user_id: current_user.id })
      .where("review_status = 'pending_review' OR sender_status = 'pending_approval'")
  end

  def expense_sort_time(expense)
    expense.trip_item&.starts_at || expense.expense_date.end_of_day
  end

  def authenticate_user!
    redirect_to app_root_path, alert: "Please sign in." unless current_user || request.path == app_root_path
  end
end
