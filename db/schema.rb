# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_28_191215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorships", force: :cascade do |t|
    t.bigint "thing_id", null: false
    t.bigint "user_id", null: false
    t.integer "confirmed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["thing_id"], name: "index_authorships_on_thing_id"
    t.index ["user_id"], name: "index_authorships_on_user_id"
  end

  create_table "cache_versions", force: :cascade do |t|
    t.string "name"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "thing_id", null: false
    t.integer "weight"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["thing_id"], name: "index_comments_on_thing_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "things", force: :cascade do |t|
    t.text "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "image_meta_data"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "auth_meta_data"
  end

  add_foreign_key "authorships", "things"
  add_foreign_key "authorships", "users"
  add_foreign_key "comments", "things"
  add_foreign_key "comments", "users"
end
