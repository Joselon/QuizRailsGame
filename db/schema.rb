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

ActiveRecord::Schema[8.0].define(version: 2025_07_13_193533) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "questions", force: :cascade do |t|
    t.string "content"
    t.string "correct_answer"
    t.string "category"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_players", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "room_id", null: false
    t.integer "score"
    t.integer "turn_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_room_players_on_room_id"
    t.index ["user_id"], name: "index_room_players_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.integer "current_turn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "turns", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "room_player_id", null: false
    t.bigint "question_id", null: false
    t.string "answer"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_turns_on_question_id"
    t.index ["room_id"], name: "index_turns_on_room_id"
    t.index ["room_player_id"], name: "index_turns_on_room_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "room_players", "rooms"
  add_foreign_key "room_players", "users"
  add_foreign_key "turns", "questions"
  add_foreign_key "turns", "room_players"
  add_foreign_key "turns", "rooms"
end
