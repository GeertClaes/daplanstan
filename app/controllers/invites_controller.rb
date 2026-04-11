class InvitesController < ApplicationController
  before_action :authenticate_user!, only: %i[index create destroy]

  # GET /i/:token — landing page for invite recipients
  def accept
    @invite = Invite.find_by(token: params[:token])

    if @invite.nil? || !@invite.usable?
      redirect_to waitlist_path, alert: "This invite link is invalid or has already been used."
      return
    end

    session[:invite_token] = @invite.token
    render :accept
  end

  # GET /waitlist
  def waitlist; end

  # GET /settings/invites
  def index
    @invites = current_user.created_invites.order(created_at: :desc)
  end

  # POST /settings/invites
  def create
    @invite = current_user.created_invites.build(invite_params)

    if @invite.save
      redirect_to settings_invites_path, notice: "Invite created."
    else
      @invites = current_user.created_invites.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /settings/invites/:id
  def destroy
    invite = current_user.created_invites.find(params[:id])
    invite.destroy!
    redirect_to settings_invites_path, notice: "Invite revoked."
  end

  private

  def invite_params
    params.permit(:email, :note, :expires_at)
  end
end
