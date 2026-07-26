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

ActiveRecord::Schema[8.1].define(version: 2026_07_26_031456) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "media", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "media_url"
    t.uuid "public_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_media_on_user_id"
  end

  create_table "post_media", force: :cascade do |t|
    t.string "caption"
    t.boolean "cover_image", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "medium_id", null: false
    t.bigint "post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["medium_id"], name: "index_post_media_on_medium_id"
    t.index ["post_id"], name: "index_post_media_on_post_id"
  end

  create_table "post_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "tag_id"], name: "index_post_tags_on_post_id_and_tag_id", unique: true
    t.index ["post_id"], name: "index_post_tags_on_post_id"
    t.index ["tag_id"], name: "index_post_tags_on_tag_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "category_id"
    t.text "content"
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.string "excerpt"
    t.string "slug"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.string "username"
  end

  add_foreign_key "media", "users"
  add_foreign_key "post_media", "media"
  add_foreign_key "post_media", "posts"
  add_foreign_key "post_tags", "posts"
  add_foreign_key "post_tags", "tags"
  add_foreign_key "posts", "categories"
  add_foreign_key "posts", "users"
end
