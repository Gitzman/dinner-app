class FavoritesController < ApplicationController
  def index
    @favorites = current_user.favorite_meal_suggestions
                              .includes(:favorites)
                              .order("user_favorites.created_at DESC")
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy
    redirect_to favorites_path, notice: "Removed from favorites"
  end
end
