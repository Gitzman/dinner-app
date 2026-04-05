require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get favorites_url
    assert_response :success
    assert_select "h1", "My Favorites"
  end

  test "should show favorited meals" do
    get favorites_url
    assert_response :success
    assert_select "h2", "Spaghetti Carbonara"
  end

  test "should show empty state when no favorites" do
    @user.favorites.destroy_all
    get favorites_url
    assert_response :success
    assert_select "h2", "No favorites yet"
  end

  test "should destroy favorite" do
    favorite = @user.favorites.first
    assert_difference("Favorite.count", -1) do
      delete favorite_url(favorite)
    end
    assert_redirected_to favorites_url
  end

  test "should not destroy another users favorite" do
    other_user = users(:two)
    other_favorite = other_user.favorites.create!(meal_suggestion: meal_suggestions(:two))
    assert_raises(ActiveRecord::RecordNotFound) do
      delete favorite_url(other_favorite)
    end
  end
end
