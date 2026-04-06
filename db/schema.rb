# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_05_223712) do
  create_table "meal_suggestions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "flow_type"
    t.text "suggestions"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.text "user_input"
    t.index ["user_id"], name: "index_meal_suggestions_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "cooking_style"
    t.text "cookware"
    t.datetime "created_at", null: false
    t.text "cuisine_preferences"
    t.text "culinary_goals"
    t.text "family_description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "user_favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "meal_suggestion_id", null: false
    t.integer "suggestion_index", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["meal_suggestion_id"], name: "index_user_favorites_on_meal_suggestion_id"
    t.index ["user_id", "meal_suggestion_id", "suggestion_index"], name: "idx_user_favorites_unique", unique: true
    t.index ["user_id"], name: "index_user_favorites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "meal_suggestions", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "user_favorites", "meal_suggestions"
  add_foreign_key "user_favorites", "users"
end
