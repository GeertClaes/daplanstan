class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def create
    auth = request.env["omniauth.auth"]

    identity = UserIdentity.find_by(provider: auth.provider, provider_uid: auth.uid)

    if identity
      user = identity.user
      user.update_columns(avatar_url: auth.info.image) if auth.info.image.present?
    else
      user = User.find_or_initialize_by(email: auth.info.email)
      user.name       ||= auth.info.name
      user.avatar_url   = auth.info.image
      user.save!

      identity = user.user_identities.create!(
        provider:       auth.provider,
        provider_uid:   auth.uid,
        provider_email: auth.info.email,
        access_token:   auth.credentials&.token
      )
    end

    session[:user_id] = user.id

    # Accept any pending traveler invitations for this email (must load before
    # accepting, because accept! sets user_id making them no longer "pending")
    pending_travelers = Traveler.where(user_id: nil, email: user.email).to_a
    pending_travelers.each { |t| t.accept!(user) }

    if user.account
      redirect_to trips_path, notice: "Signed in as #{user.name}"
    elsif user.traveler_profiles.exists?
      # Member of someone else's account (via invite) — no account of their own needed
      redirect_to trips_path, notice: "Welcome, #{user.name}!"
    else
      provision_account_or_gate(user)
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to app_root_path, notice: "Signed out."
  end

  def failure
    redirect_to app_root_path, alert: "Authentication failed: #{params[:message]}"
  end

  private

  def provision_account_or_gate(user)
    # OPEN_SIGNUP=true bypasses the invite gate (local dev / self-hosted)
    if ENV["OPEN_SIGNUP"] == "true"
      create_account_for(user)
      Traveler.where(user_id: nil, email: user.email).find_each { |t| t.accept!(user) }
      redirect_to trips_path, notice: "Welcome to Daplanstan, #{user.name}!"
      return
    end

    token  = session.delete(:invite_token)
    invite = Invite.find_by(token: token)

    if invite&.usable? && invite.email_matches?(user.email)
      create_account_for(user)
      invite.update!(used_by: user, used_at: Time.current)
      Traveler.where(user_id: nil, email: user.email).find_each { |t| t.accept!(user) }
      redirect_to trips_path, notice: "Welcome to the beta, #{user.name}! Your account is ready."
    else
      # Sign them back out — no account, no invite
      session.delete(:user_id)
      redirect_to waitlist_path, alert: "You need a valid invite link to join the beta."
    end
  end

  def create_account_for(user)
    account = Account.create!(owner: user, name: user.name)
    account.travelers.create!(user: user, name: user.name, email: user.email, avatar_url: user.avatar_url)
  end
end
