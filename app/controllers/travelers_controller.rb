class TravelersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def create
    name  = params[:name].presence&.strip
    email = params[:email].presence&.strip&.downcase

    return redirect_to settings_path, alert: "Please enter a name." unless name

    if email
      return redirect_to settings_path, alert: "That's you." if email == current_user.email

      existing = @account.travelers.find_by(email: email) ||
                 @account.travelers.joins(:user).find_by(users: { email: email })
      return redirect_to settings_path, alert: "#{email} is already in your account." if existing

      linked_user = User.find_by(email: email)
      if linked_user
        @account.travelers.create!(user: linked_user, name: name, email: linked_user.email, avatar_url: linked_user.avatar_url)
      else
        @account.travelers.create!(name: name, email: email)
      end
      InvitationMailer.invite(current_user, email).deliver_later
      redirect_to settings_path, notice: "Invite sent to #{email}."
    else
      # Name-only — no login
      traveler = @account.travelers.build(name: name)
      if traveler.save
        redirect_to settings_path, notice: "#{name} added."
      else
        redirect_to settings_path, alert: traveler.errors.full_messages.first
      end
    end
  end

  def update
    traveler = @account.travelers.find(params[:id])
    if traveler.update(traveler_params)
      redirect_to settings_path, notice: "Updated."
    else
      redirect_to settings_path, alert: traveler.errors.full_messages.first
    end
  end

  def destroy
    traveler = @account.travelers.find(params[:id])
    traveler.destroy!
    redirect_to settings_path, notice: "Removed from account."
  end

  private

  def set_account
    @account = current_account
    redirect_to root_path, alert: "No account found." unless @account&.owner == current_user
  end

  def traveler_params
    params.require(:traveler).permit(:name, :avatar_url)
  end
end
