class ApplicationController < ActionController::Base
  stale_when_importmap_changes

  before_action :authenticate_user!
  before_action :redirect_to_profile_if_incomplete, if: :user_signed_in?

  private

  def redirect_to_profile_if_incomplete
    return if request.path.start_with?("/profile")
    if current_user.profile.name.blank?
      redirect_to edit_profile_path, notice: "Complete your profile first"
    end
  end
end
