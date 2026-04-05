class AddSuggestionIndexToUserFavorites < ActiveRecord::Migration[8.1]
  def change
    add_column :user_favorites, :suggestion_index, :integer, null: false, default: 0

    remove_index :user_favorites, [:user_id, :meal_suggestion_id]
    add_index :user_favorites, [:user_id, :meal_suggestion_id, :suggestion_index], unique: true, name: "idx_user_favorites_unique"
  end
end
