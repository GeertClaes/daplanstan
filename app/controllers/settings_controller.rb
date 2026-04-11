class SettingsController < ApplicationController
  before_action :authenticate_user!
  helper_method :settings_back_path

  def show
    @account   = current_account
    @travelers = @account&.travelers&.includes(:user)&.order(:name) || []
    @identities = current_user.user_identities
  end

  def update
    if current_user.update(settings_params)
      current_account&.update(name: current_user.name)
      redirect_to settings_path, notice: "Settings saved."
    else
      @account    = current_account
      @travelers  = @account&.travelers&.includes(:user)&.order(:name) || []
      @identities = current_user.user_identities
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:user).permit(:name, :theme)
  end

  def settings_back_path
    back = params[:back]
    back.present? && back.start_with?("/") && !back.start_with?("//") ? back : trips_path
  end
end
