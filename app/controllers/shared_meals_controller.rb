class SharedMealsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :redirect_to_profile_if_incomplete

  def show
    @meal = MealSuggestion.find(params[:id])
    @suggestions = @meal.suggestions.map(&:deep_symbolize_keys)

    session[:ref] = params[:ref] if params[:ref].present?

    if user_signed_in?
      @favorited_indices = current_user.favorites.where(meal_suggestion: @meal).pluck(:suggestion_index).to_set
    else
      @favorited_indices = Set.new
    end
  end
end
