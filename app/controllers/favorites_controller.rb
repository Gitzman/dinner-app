class FavoritesController < ApplicationController
  def index
    @favorites = current_user.favorites
                              .includes(:meal_suggestion)
                              .order(created_at: :desc)

    meal_ids = @favorites.map(&:meal_suggestion_id).uniq
    @interaction_stats = RecipeInteraction
      .where(meal_suggestion_id: meal_ids, is_deleted: false)
      .group(:meal_suggestion_id, :suggestion_index)
      .pluck(:meal_suggestion_id, :suggestion_index, Arel.sql("COUNT(*)"), Arel.sql("AVG(recipe_rating)"), Arel.sql("AVG(kid_tip_rating)"))
      .to_h { |ms_id, si, count, avg_rating, avg_kid| [ [ ms_id, si ], { made_count: count, avg_recipe_rating: avg_rating&.to_f, avg_kid_tip_rating: avg_kid&.to_f } ] }
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy
    redirect_to favorites_path, notice: "Removed from favorites"
  end
end
