require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @meal = meal_suggestions(:one)
    sign_in @user
  end

  # POST /meals/:id/rate

  test "rate creates a new interaction" do
    RecipeInteraction.where(user: @user, meal_suggestion: @meal).destroy_all
    assert_difference "RecipeInteraction.count", 1 do
      post rate_meal_path(@meal), params: { suggestion_index: 0, recipe_rating: 5 }
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 0, json["suggestion_index"]
    assert_equal 5, json["recipe_rating"]
    assert_nil json["kid_tip_rating"]
  end

  test "rate creates interaction with kid_tip_rating" do
    RecipeInteraction.where(user: @user, meal_suggestion: @meal).destroy_all
    post rate_meal_path(@meal), params: { suggestion_index: 0, recipe_rating: 4, kid_tip_rating: 3 }
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 4, json["recipe_rating"]
    assert_equal 3, json["kid_tip_rating"]
  end

  test "rate updates existing interaction within 24 hours" do
    RecipeInteraction.where(user: @user, meal_suggestion: @meal).destroy_all
    interaction = RecipeInteraction.create!(
      user: @user, meal_suggestion: @meal,
      suggestion_index: 0, recipe_rating: 3,
      created_at: 1.hour.ago
    )

    assert_no_difference "RecipeInteraction.count" do
      post rate_meal_path(@meal), params: { suggestion_index: 0, recipe_rating: 5 }
    end
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal 5, json["recipe_rating"]
    assert_equal interaction.id, json["id"]
  end

  test "rate creates new interaction after 24-hour window" do
    RecipeInteraction.where(user: @user, meal_suggestion: @meal).destroy_all
    RecipeInteraction.create!(
      user: @user, meal_suggestion: @meal,
      suggestion_index: 0, recipe_rating: 3,
      created_at: 25.hours.ago
    )

    assert_difference "RecipeInteraction.count", 1 do
      post rate_meal_path(@meal), params: { suggestion_index: 0, recipe_rating: 4 }
    end
    assert_response :created
  end

  test "rate ignores deleted interactions in 24-hour window" do
    RecipeInteraction.where(user: @user, meal_suggestion: @meal).destroy_all
    RecipeInteraction.create!(
      user: @user, meal_suggestion: @meal,
      suggestion_index: 0, recipe_rating: 3,
      is_deleted: true, created_at: 1.hour.ago
    )

    assert_difference "RecipeInteraction.count", 1 do
      post rate_meal_path(@meal), params: { suggestion_index: 0, recipe_rating: 4 }
    end
    assert_response :created
  end

  test "rate requires authentication" do
    sign_out @user
    post rate_meal_path(@meal), params: { suggestion_index: 0, recipe_rating: 5 }
    assert_response :redirect
  end

  # GET /meals/:id/ratings

  test "ratings returns aggregated data" do
    RecipeInteraction.where(meal_suggestion: @meal).destroy_all
    RecipeInteraction.create!(user: @user, meal_suggestion: @meal, suggestion_index: 0, recipe_rating: 4, kid_tip_rating: 4)
    RecipeInteraction.create!(user: users(:two), meal_suggestion: @meal, suggestion_index: 0, recipe_rating: 2, kid_tip_rating: 3)

    get ratings_meal_path(@meal)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json.length

    entry = json.first
    assert_equal 0, entry["suggestion_index"]
    assert_equal 2, entry["made_count"]
    assert_equal 3.0, entry["avg_recipe_rating"]
    assert_equal 3.5, entry["avg_kid_tip_rating"]
    assert_equal false, entry["mini_sous_chef_approved"]
  end

  test "ratings excludes deleted interactions" do
    RecipeInteraction.where(meal_suggestion: @meal).destroy_all
    RecipeInteraction.create!(user: @user, meal_suggestion: @meal, suggestion_index: 0, recipe_rating: 5, kid_tip_rating: 5)
    RecipeInteraction.create!(user: users(:two), meal_suggestion: @meal, suggestion_index: 0, recipe_rating: 1, is_deleted: true)

    get ratings_meal_path(@meal)
    json = JSON.parse(response.body)
    assert_equal 1, json.first["made_count"]
    assert_equal 5.0, json.first["avg_recipe_rating"]
  end

  test "ratings is public (no auth required)" do
    sign_out @user
    get ratings_meal_path(@meal)
    assert_response :success
  end

  test "ratings returns empty array when no interactions" do
    RecipeInteraction.where(meal_suggestion: @meal).destroy_all
    get ratings_meal_path(@meal)
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "ratings shows mini_sous_chef_approved when avg kid_tip > 3.5" do
    RecipeInteraction.where(meal_suggestion: @meal).destroy_all
    RecipeInteraction.create!(user: @user, meal_suggestion: @meal, suggestion_index: 0, recipe_rating: 4, kid_tip_rating: 5)
    RecipeInteraction.create!(user: users(:two), meal_suggestion: @meal, suggestion_index: 0, recipe_rating: 4, kid_tip_rating: 4)

    get ratings_meal_path(@meal)
    json = JSON.parse(response.body)
    assert_equal true, json.first["mini_sous_chef_approved"]
  end
end
