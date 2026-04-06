class RecipeInteraction < ApplicationRecord
  belongs_to :user
  belongs_to :meal_suggestion

  validates :recipe_rating, inclusion: { in: 1..5 }
  validates :kid_tip_rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :suggestion_index, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
