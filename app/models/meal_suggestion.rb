class MealSuggestion < ApplicationRecord
  belongs_to :user
  has_many :favorites
  has_many :favorited_by_users, through: :favorites, source: :user
  has_many :recipe_interactions

  serialize :suggestions, coder: JSON
end
