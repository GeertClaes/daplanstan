class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [ :show ]
  before_action :set_editable_trip, only: [ :edit, :update, :cover, :update_cover, :refresh_cover, :travelers ]
  before_action :set_owner_trip, only: [ :destroy, :regenerate_inbound_email ]

  def index
    @pagy, @trips = pagy(current_user.trips.includes(trip_members: :traveler).order(start_date: :asc))
  end

  def show
    @trip_items = @trip.trip_items
                       .order(Arel.sql("starts_at IS NULL, starts_at ASC, created_at ASC"))
    @expenses = @trip.expenses
                     .includes(:paid_by, :confirmed_by, :trip_item)
                     .sort_by { |e| expense_sort_time(e) }
    @members  = @trip.trip_members.includes(:traveler)

    @map_trip_items_json = @trip_items.map do |i|
      { id: i.id, name: i.name, kind: i.kind, status: i.status,
        when_label: i.when_label,
        latitude: i.latitude, longitude: i.longitude }
    end.to_json

    @inbox_items = @trip.inbox_items.order(received_at: :desc).limit(50)
    @inbox_pending_count = @trip.inbox_items.where(review_status: :pending_review).count
    @is_owner = current_member_for(@trip)&.owner?
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = Trip.new(trip_params)
    @trip.created_by = current_user
    @trip.account    = current_account

    if @trip.save
      owner_traveler = current_account.owner_traveler
      @trip.trip_members.create!(traveler: owner_traveler, role: :owner, joined_at: Time.current)
      FetchTripCoverImageJob.perform_later(@trip.id)
      redirect_to @trip, notice: "Trip created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def cover
  end

  def update_cover
    if params[:cover_image].present?
      @trip.cover_image.attach(params[:cover_image])
      @trip.update_columns(cover_image_url: nil)
    end
    redirect_to cover_trip_path(@trip)
  end

  def travelers
    @members = @trip.trip_members.includes(:traveler).order(:role, created_at: :asc)
  end

  def update
    if @trip.update(trip_params)
      FetchTripCoverImageJob.perform_later(@trip.id) if trip_params[:title].present?
      redirect_to @trip, notice: "Trip updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: "Trip deleted."
  end

  def regenerate_inbound_email
    @trip.regenerate_inbound_email!
    redirect_to edit_trip_path(@trip), notice: "New inbound email address generated."
  end

  def refresh_cover
    @trip.cover_image.purge if @trip.cover_image.attached?
    @trip.update_columns(cover_image_url: nil)
    FetchTripCoverImageJob.perform_now(@trip.id)
    redirect_to cover_trip_path(@trip)
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def set_editable_trip
    @trip = Trip.joins(trip_members: :traveler)
                .where(travelers: { user_id: current_user.id })
                .where(trip_members: { role: [ "owner", "planner" ] })
                .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to trips_path, alert: "You don't have permission to do that."
  end

  def set_owner_trip
    @trip = Trip.joins(trip_members: :traveler)
                .where(travelers: { user_id: current_user.id })
                .where(trip_members: { role: "owner" })
                .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to trips_path, alert: "You don't have permission to do that."
  end

  def trip_params
    params.require(:trip).permit(:title, :description, :start_date, :end_date)
  end
end
