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

ActiveRecord::Schema[7.0].define(version: 2022_10_16_221328) do
  create_table "albums", force: :cascade do |t|
    t.integer "year"
    t.string "title", null: false
    t.string "country"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imageuri"
    t.integer "discogs_id"
    t.string "catalog_num"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.string "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imageuri"
    t.integer "discogs_id", null: false
  end

  create_table "artists_labels", id: false, force: :cascade do |t|
    t.integer "label_id", null: false
    t.integer "artist_id", null: false
  end

  create_table "artists_albums", id: false, force: :cascade do |t|
    t.integer "album_id", null: false
    t.integer "artist_id", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres_albums", id: false, force: :cascade do |t|
    t.integer "genre_id", null: false
    t.integer "album_id", null: false
  end

  create_table "labels", force: :cascade do |t|
    t.string "name", null: false
    t.string "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imageuri"
    t.integer "discogs_id", null: false
  end

  create_table "labels_albums", id: false, force: :cascade do |t|
    t.integer "album_id", null: false
    t.integer "label_id", null: false
  end

  create_table "albums_dg_tmp", force: :cascade do |t|
    t.integer "year"
    t.string "title", null: false
    t.string "country"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imageuri"
    t.integer "discogs_id", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "tracks", force: :cascade do |t|
    t.integer "position"
    t.string "title", null: false
    t.string "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "album_id", null: false
    t.index ["album_id"], name: "index_tracks_on_album_id"
  end

  create_table "videos", force: :cascade do |t|
    t.string "title", null: false
    t.string "uri", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "album_id", null: false
    t.index ["album_id"], name: "index_videos_on_album_id"
  end

  add_foreign_key "artists_labels", "artists", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "artists_labels", "labels", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "artists_albums", "albums", column: "album_id", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "artists_albums", "artists", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "genres_albums", "albums", column: "album_id", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "genres_albums", "genres", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "labels_albums", "albums", column: "album_id", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "labels_albums", "labels", primary_key: "id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tracks", "albums", column: "album_id"
  add_foreign_key "videos", "albums", column: "album_id"
end
