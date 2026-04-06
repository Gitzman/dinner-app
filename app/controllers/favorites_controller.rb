class FavoritesController < ApplicationController
  def index
    @favorites = current_user.favorites
                              .includes(:meal_suggestion)
                              .order(created_at: :desc)
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy
    redirect_to favorites_path, notice: "Removed from favorites"
  end
end
