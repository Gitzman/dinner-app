class CreateRecipeInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_interactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :meal_suggestion, null: false, foreign_key: true
      t.integer :suggestion_index, null: false
      t.integer :recipe_rating, null: false
      t.integer :kid_tip_rating
      t.boolean :is_deleted, default: false, null: false

      t.timestamps
    end

    add_index :recipe_interactions, [:user_id, :meal_suggestion_id, :suggestion_index],
              name: "idx_recipe_interactions_user_suggestion"
  end
end
