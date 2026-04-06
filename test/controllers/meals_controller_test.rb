require "test_helper"

class MealsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @meal = meal_suggestions(:one)
    sign_in @user
  end

  test "show renders suggestions with favorited meal" do
    get meal_path(@meal)
    assert_response :success
    assert_select "h2", "Spaghetti Carbonara"
  end

  test "show renders when no favorites exist" do
    Favorite.where(user: @user, meal_suggestion: @meal).destroy_all
    get meal_path(@meal)
    assert_response :success
    assert_select "h2", "Spaghetti Carbonara"
  end

  test "favorite creates favorite when not yet favorited" do
    Favorite.where(user: @user, meal_suggestion: @meal).destroy_all
    assert_difference "Favorite.count", 1 do
      post favorite_meal_path(@meal, suggestion_index: 0)
    end
    assert_response :created
  end

  test "favorite removes favorite when already favorited" do
    Favorite.find_or_create_by!(user: @user, meal_suggestion: @meal, suggestion_index: 0)
    assert_difference "Favorite.count", -1 do
      post favorite_meal_path(@meal, suggestion_index: 0)
    end
    assert_response :ok
  end

  test "favorite requires authentication" do
    sign_out @user
    post favorite_meal_path(@meal, suggestion_index: 0)
    assert_response :redirect
  end
end
