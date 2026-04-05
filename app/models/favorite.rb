class Favorite < ApplicationRecord
  self.table_name = "user_favorites"

  belongs_to :user
  belongs_to :meal_suggestion

  validates :meal_suggestion_id, uniqueness: { scope: [:user_id, :suggestion_index] }
  validates :suggestion_index, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
