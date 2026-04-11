class HomeController < ApplicationController
  layout "landing"
  skip_before_action :authenticate_user!, raise: false

  # whats.daplanstan.com — app sign-in page
  def app
    redirect_to trips_path if current_user
  end

  def privacy; end
  def terms; end
end
