class CreateMealSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_suggestions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :flow_type
      t.text :user_input
      t.text :suggestions

      t.timestamps
    end
  end
end
