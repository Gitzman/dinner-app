require "test_helper"

class RecipeInteractionTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "test@example.com", password: "password123456")
    @meal_suggestion = MealSuggestion.create!(user: @user, suggestions: "[]")
    @attrs = { user: @user, meal_suggestion: @meal_suggestion, suggestion_index: 0, recipe_rating: 4 }
  end

  test "valid with all required attributes" do
    interaction = RecipeInteraction.new(@attrs)
    assert interaction.valid?
  end

  test "valid with optional kid_tip_rating" do
    interaction = RecipeInteraction.new(@attrs.merge(kid_tip_rating: 3))
    assert interaction.valid?
  end

  test "invalid without recipe_rating" do
    interaction = RecipeInteraction.new(@attrs.except(:recipe_rating))
    assert_not interaction.valid?
  end

  test "invalid with recipe_rating outside 1..5" do
    interaction = RecipeInteraction.new(@attrs.merge(recipe_rating: 0))
    assert_not interaction.valid?

    interaction = RecipeInteraction.new(@attrs.merge(recipe_rating: 6))
    assert_not interaction.valid?
  end

  test "invalid with kid_tip_rating outside 1..5" do
    interaction = RecipeInteraction.new(@attrs.merge(kid_tip_rating: 0))
    assert_not interaction.valid?

    interaction = RecipeInteraction.new(@attrs.merge(kid_tip_rating: 6))
    assert_not interaction.valid?
  end

  test "kid_tip_rating can be nil" do
    interaction = RecipeInteraction.new(@attrs.merge(kid_tip_rating: nil))
    assert interaction.valid?
  end

  test "belongs to user" do
    interaction = RecipeInteraction.create!(@attrs)
    assert_equal @user, interaction.user
  end

  test "belongs to meal_suggestion" do
    interaction = RecipeInteraction.create!(@attrs)
    assert_equal @meal_suggestion, interaction.meal_suggestion
  end

  test "user has_many recipe_interactions" do
    RecipeInteraction.create!(@attrs)
    assert_equal 1, @user.recipe_interactions.count
  end

  test "meal_suggestion has_many recipe_interactions" do
    RecipeInteraction.create!(@attrs)
    assert_equal 1, @meal_suggestion.recipe_interactions.count
  end

  test "is_deleted defaults to false" do
    interaction = RecipeInteraction.create!(@attrs)
    assert_equal false, interaction.is_deleted
  end
end
