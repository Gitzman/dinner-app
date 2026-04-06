class RatingsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  skip_before_action :redirect_to_profile_if_incomplete, only: :index

  # POST /meals/:meal_id/rate
  def create
    meal = current_user.meal_suggestions.find(params[:id])
    suggestion_index = params[:suggestion_index].to_i

    interaction = current_user.recipe_interactions
      .where(meal_suggestion: meal, suggestion_index: suggestion_index, is_deleted: false)
      .where("created_at > ?", 24.hours.ago)
      .order(created_at: :desc)
      .first

    if interaction
      interaction.update!(interaction_params)
      status = :ok
    else
      interaction = current_user.recipe_interactions.create!(
        meal_suggestion: meal,
        suggestion_index: suggestion_index,
        **interaction_params
      )
      status = :created
    end

    render json: {
      id: interaction.id,
      suggestion_index: interaction.suggestion_index,
      recipe_rating: interaction.recipe_rating,
      kid_tip_rating: interaction.kid_tip_rating,
      created_at: interaction.created_at,
      updated_at: interaction.updated_at
    }, status: status
  end

  # GET /meals/:meal_id/ratings
  def index
    meal = MealSuggestion.find(params[:id])
    interactions = meal.recipe_interactions.where(is_deleted: false)

    ratings = interactions.group(:suggestion_index).select(
      "suggestion_index",
      "COUNT(*) AS made_count",
      "AVG(recipe_rating) AS avg_recipe_rating",
      "AVG(kid_tip_rating) AS avg_kid_tip_rating"
    )

    render json: ratings.map { |r|
      {
        suggestion_index: r.suggestion_index,
        made_count: r.made_count,
        avg_recipe_rating: r.avg_recipe_rating&.round(1)&.to_f,
        avg_kid_tip_rating: r.avg_kid_tip_rating&.round(1)&.to_f,
        mini_sous_chef_approved: r.avg_kid_tip_rating.present? && r.avg_kid_tip_rating > 3.5
      }
    }
  end

  private

  def interaction_params
    params.permit(:recipe_rating, :kid_tip_rating)
  end
end
