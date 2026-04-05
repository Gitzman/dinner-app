class CreateUserFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :user_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meal_suggestion, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_favorites, [:user_id, :meal_suggestion_id], unique: true
  end
end
