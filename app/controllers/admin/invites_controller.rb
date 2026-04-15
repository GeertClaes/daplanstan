class Admin::InvitesController < Admin::ApplicationController
  def index
    @invites = Invite.order(created_at: :desc)
  end

  def create
    @invite = current_user.created_invites.build(invite_params)

    if @invite.save
      redirect_to admin_invites_path, notice: "Invite created."
    else
      @invites = Invite.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    Invite.find(params[:id]).destroy!
    redirect_to admin_invites_path, notice: "Invite revoked."
  end

  private

  def invite_params
    params.permit(:email, :note, :expires_at)
  end
end
