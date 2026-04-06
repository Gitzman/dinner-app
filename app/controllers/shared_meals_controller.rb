class SharedMealsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :redirect_to_profile_if_incomplete

  def show
    @meal = MealSuggestion.find(params[:id])
    all_suggestions = @meal.suggestions.map(&:deep_symbolize_keys)

    session[:ref] = params[:ref] if params[:ref].present?

    if params[:si].present?
      si = params[:si].to_i
      @suggestions = [all_suggestions[si]].compact
      @suggestion_offset = si
    else
      @suggestions = all_suggestions
      @suggestion_offset = 0
    end

    if user_signed_in?
      @favorited_indices = current_user.favorites.where(meal_suggestion: @meal).pluck(:suggestion_index).to_set
    else
      @favorited_indices = Set.new
    end
  end
end
