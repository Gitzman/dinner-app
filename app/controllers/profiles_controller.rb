class ProfilesController < ApplicationController
  skip_before_action :redirect_to_profile_if_incomplete

  def edit
    @profile = current_user.profile
  end

  def update
    @profile = current_user.profile
    if @profile.update(profile_params)
      redirect_to meals_path, notice: "Profile saved!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    p = params.require(:profile).permit(
      :name, :family_description, :cooking_style, :culinary_goals,
      cookware_items: [], cuisine_items: []
    )
    p[:cookware] = Array(p.delete(:cookware_items)).join(", ")
    p[:cuisine_preferences] = Array(p.delete(:cuisine_items)).join(", ")
    p
  end
end
