class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile
  has_many :meal_suggestions
  has_many :favorites
  has_many :favorite_meal_suggestions, through: :favorites, source: :meal_suggestion

  after_create :create_profile
end
