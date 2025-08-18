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

ActiveRecord::Schema[8.0].define(version: 2025_08_18_063424) do
  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "x_id"
    t.string "x_username"
    t.string "x_name"
    t.string "x_profile_image_url"
  end

  create_table "x_accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "username"
    t.string "image"
    t.string "token"
    t.string "secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_x_accounts_on_user_id"
  end

  create_table "x_posts", force: :cascade do |t|
    t.text "content"
    t.datetime "scheduled_at"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "x_account_id", null: false
    t.text "body"
    t.datetime "publish_at"
    t.string "x_post_id"
    t.index ["user_id"], name: "index_x_posts_on_user_id"
    t.index ["x_account_id"], name: "index_x_posts_on_x_account_id"
  end

  create_table "xes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "xaccount_id", null: false
    t.text "body"
    t.datetime "publish_at"
    t.string "tweet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_xes_on_user_id"
    t.index ["xaccount_id"], name: "index_xes_on_xaccount_id"
  end

  add_foreign_key "x_accounts", "users"
  add_foreign_key "x_posts", "users"
  add_foreign_key "x_posts", "x_accounts"
  add_foreign_key "xes", "users"
  add_foreign_key "xes", "xaccounts"
end
