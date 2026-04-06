class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile
  has_many :meal_suggestions
  has_many :favorites
  has_many :favorite_meal_suggestions, through: :favorites, source: :meal_suggestion
  belongs_to :referrer, class_name: "User", optional: true, foreign_key: "referred_by"

  after_create :create_profile
end
