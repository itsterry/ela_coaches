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

ActiveRecord::Schema[8.1].define(version: 2026_08_04_111446) do
  create_table "availabilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "finish_time", null: false
    t.integer "slot_length", null: false
    t.time "start_time", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.boolean "zoom", default: false, null: false
    t.index ["coach_id"], name: "index_availabilities_on_coach_id"
    t.index ["status", "date"], name: "index_availabilities_on_status_and_date"
  end

  create_table "coaches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "password_digest", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "zoom_account_id"
    t.string "zoom_client_id"
    t.string "zoom_client_secret"
    t.index ["email"], name: "index_coaches_on_email", unique: true
    t.index ["slug"], name: "index_coaches_on_slug", unique: true
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["coach_id"], name: "index_sessions_on_coach_id"
  end

  create_table "slots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "availability_id", null: false
    t.datetime "created_at", null: false
    t.string "parent_email", null: false
    t.string "parent_name", null: false
    t.string "player_name", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.index ["availability_id", "parent_email"], name: "index_slots_on_availability_id_and_parent_email", unique: true
    t.index ["availability_id", "start_time"], name: "index_slots_on_availability_id_and_start_time", unique: true
    t.index ["availability_id"], name: "index_slots_on_availability_id"
    t.index ["uuid"], name: "index_slots_on_uuid", unique: true
  end

  add_foreign_key "availabilities", "coaches"
  add_foreign_key "sessions", "coaches"
  add_foreign_key "slots", "availabilities"
end
