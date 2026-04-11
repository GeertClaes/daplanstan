class InboxItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_item, only: [ :show, :update, :destroy ]

  def index
    @pagy, @items = pagy(@trip.inbox_items.order(received_at: :desc))
  end

  def show
    @trip_items     = @item.trip_items.includes(:expense)
    @primary_item   = @trip_items.first
    @primary_expense = @trip_items.filter_map(&:expense).first
  end

  def update
    case params[:action_type]
    when "confirm"
      @item.confirm_and_create_items!(current_user)
      @item.update!(review_status: :confirmed, reviewed_by: current_user, reviewed_at: Time.current)
      redirect_to trip_inbox_item_path(@trip, @item), notice: "Added to trip."
    when "discard"
      @item.update!(review_status: :discarded, reviewed_by: current_user, reviewed_at: Time.current)
      redirect_to trip_inbox_items_path(@trip), notice: "Discarded."
    when "retry"
      @item.update!(parse_status: :unparsed)
      ParseInboxItemJob.perform_later(@item.id)
      redirect_to trip_inbox_items_path(@trip), notice: "Retrying \u2014 check back in a moment."
    else
      redirect_to trip_inbox_items_path(@trip)
    end
  end

  def destroy
    @item.destroy!
    redirect_to trip_inbox_items_path(@trip), notice: "Email deleted."
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:trip_id])
  end

  def set_item
    @item = @trip.inbox_items.find(params[:id])
  end
end
