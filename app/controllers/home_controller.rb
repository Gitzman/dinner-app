class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :redirect_to_profile_if_incomplete

  def index
    redirect_to meals_path if user_signed_in?
  end
end
