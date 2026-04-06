class SharedMealsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :redirect_to_profile_if_incomplete

  def show
    @meal = MealSuggestion.find(params[:id])
    all_suggestions = @meal.suggestions.map(&:deep_symbolize_keys)

    session[:ref] = params[:ref] if params[:ref].present?

    if params[:slug].present?
      si = all_suggestions.index { |s| slug_for(s[:name]) == params[:slug] }
      si ||= params[:si]&.to_i
    elsif params[:si].present?
      si = params[:si].to_i
    end

    if si
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

    @interaction_stats = RecipeInteraction
      .where(meal_suggestion: @meal, is_deleted: false)
      .group(:suggestion_index)
      .pluck(:suggestion_index, Arel.sql("COUNT(*)"), Arel.sql("AVG(recipe_rating)"), Arel.sql("AVG(kid_tip_rating)"))
      .to_h { |si, count, avg_rating, avg_kid| [ si, { made_count: count, avg_recipe_rating: avg_rating&.to_f, avg_kid_tip_rating: avg_kid&.to_f } ] }
  end

  private

  def slug_for(name)
    name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
  end
  helper_method :slug_for
end
