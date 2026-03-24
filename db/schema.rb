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

ActiveRecord::Schema[8.1].define(version: 2026_03_24_053124) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "menu_items", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_available", default: true
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.bigint "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_menu_items_on_restaurant_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "opening_hours"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "jti"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
  end

  add_foreign_key "menu_items", "restaurants"
end
