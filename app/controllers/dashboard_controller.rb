class DashboardController < ApplicationController
  def show
    @total_users = User.count
    @profiles_completed = Profile.where.not(name: [nil, ""]).count
    @total_suggestions = MealSuggestion.count
    @by_flow_type = MealSuggestion.group(:flow_type).count
    @by_user = MealSuggestion
      .joins("INNER JOIN profiles ON profiles.user_id = meal_suggestions.user_id")
      .group("profiles.name")
      .order("count_all desc")
      .count
    @recent_suggestions = MealSuggestion
      .joins("INNER JOIN profiles ON profiles.user_id = meal_suggestions.user_id")
      .select("meal_suggestions.*, profiles.name as user_name")
      .order(created_at: :desc)
      .limit(10)
  end
end
