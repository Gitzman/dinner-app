class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :family_description
      t.text :cookware
      t.text :cuisine_preferences
      t.string :cooking_style
      t.text :culinary_goals

      t.timestamps
    end
  end
end
