class MealsController < ApplicationController
  def index
    @recent = current_user.meal_suggestions.order(created_at: :desc).limit(5)
    @last_flow = @recent.first&.flow_type
  end

  def new
    @flow_type = params[:flow]
  end

  def create
    flow_type = params[:flow_type]
    user_input = params[:user_input].to_s.strip

    suggestions = MealSuggester.call(current_user, flow_type: flow_type, user_input: user_input)

    @meal = current_user.meal_suggestions.create!(
      flow_type: flow_type,
      user_input: user_input,
      suggestions: suggestions.map { |s|
        {
          name: s.name,
          description: s.description,
          estimated_time: s.estimated_time,
          cookware_used: s.cookware_used,
          ingredients: s.ingredients,
          instructions: s.instructions,
          kid_contribution: s.kid_contribution
        }
      }.to_json
    )

    redirect_to meal_path(@meal)
  rescue => e
    redirect_to meals_path, alert: "Something went wrong: #{e.message}"
  end

  def show
    @meal = current_user.meal_suggestions.find(params[:id])
    @suggestions = JSON.parse(@meal.suggestions, symbolize_names: true)
    @favorited_indices = current_user.favorites.where(meal_suggestion: @meal).pluck(:suggestion_index).to_set
  end

  def favorite
    @meal = current_user.meal_suggestions.find(params[:id])
    suggestion_index = params[:suggestion_index].to_i

    existing = current_user.favorites.find_by(meal_suggestion: @meal, suggestion_index: suggestion_index)

    if existing
      existing.destroy!
      head :ok
    else
      current_user.favorites.create!(meal_suggestion: @meal, suggestion_index: suggestion_index)
      head :created
    end
  end
end
