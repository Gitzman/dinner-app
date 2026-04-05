require "test_helper"

class MealsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @meal = meal_suggestions(:one)
    sign_in @user
  end

  test "show sets is_favorited to true when meal is favorited" do
    Favorite.create!(user: @user, meal_suggestion: @meal)
    get meal_path(@meal)
    assert_response :success
    assert assigns(:is_favorited)
  end

  test "show sets is_favorited to false when meal is not favorited" do
    Favorite.where(user: @user, meal_suggestion: @meal).destroy_all
    get meal_path(@meal)
    assert_response :success
    assert_not assigns(:is_favorited)
  end

  test "favorite creates favorite and returns json when not yet favorited" do
    Favorite.where(user: @user, meal_suggestion: @meal).destroy_all
    assert_difference "Favorite.count", 1 do
      post favorite_meal_path(@meal)
    end
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json["favorited"]
  end

  test "favorite removes favorite and returns json when already favorited" do
    Favorite.find_or_create_by!(user: @user, meal_suggestion: @meal)
    assert_difference "Favorite.count", -1 do
      post favorite_meal_path(@meal)
    end
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json["favorited"]
  end

  test "favorite requires authentication" do
    sign_out @user
    post favorite_meal_path(@meal)
    assert_response :redirect
  end
end
