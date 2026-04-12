class TripMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :require_owner_or_planner

  def create
    if params[:traveler_id].present?
      traveler = @trip.account.travelers.find(params[:traveler_id])
      add_traveler(traveler)
    elsif params[:email].present?
      resolve_and_add_by_email(params[:email].strip.downcase)
    else
      redirect_to travelers_trip_path(@trip), alert: "Please provide an email."
    end
  end

  def destroy
    member = @trip.trip_members.find(params[:id])
    return redirect_to travelers_trip_path(@trip), alert: "Cannot remove the trip owner." if member.owner?
    member.destroy!
    redirect_to travelers_trip_path(@trip), notice: "Traveler removed."
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:trip_id])
  end

  def require_owner_or_planner
    member = current_member_for(@trip)
    unless member&.owner? || member&.planner?
      redirect_to @trip, alert: "Only trip owners and planners can manage travelers."
    end
  end

  def add_traveler(traveler)
    if @trip.trip_members.exists?(traveler: traveler)
      redirect_to travelers_trip_path(@trip), alert: "#{traveler.name} is already on this trip."
    else
      @trip.trip_members.create!(traveler: traveler, role: :contributor, joined_at: Time.current)
      redirect_to travelers_trip_path(@trip), notice: "#{traveler.name} added to trip."
    end
  end

  def resolve_and_add_by_email(email)
    account = @trip.account

    traveler = account.travelers.find_by(email: email) ||
               account.travelers.joins(:user).find_by(users: { email: email })

    unless traveler
      user = User.find_by(email: email)
      if user
        traveler = account.travelers.create!(
          user: user, name: user.name, email: user.email, avatar_url: user.avatar_url
        )
      else
        traveler = account.travelers.create!(name: email.split("@").first, email: email)
        InvitationMailer.invite_to_trip(account.owner, email, @trip).deliver_later
      end
    end

    add_traveler(traveler)
  end
end
