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

ActiveRecord::Schema[8.1].define(version: 2026_09_16_002840) do
  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_at"
    t.string "note"
    t.datetime "start_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_availabilities_on_user_id"
  end

  create_table "business_hours", force: :cascade do |t|
    t.time "break_end_time"
    t.time "break_start_time"
    t.datetime "created_at", null: false
    t.time "end_time"
    t.integer "interview_duration_minutes"
    t.integer "slot_interval_minutes"
    t.time "start_time"
    t.datetime "updated_at", null: false
  end

  create_table "candidates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interview_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "interview_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["interview_id"], name: "index_interview_assignments_on_interview_id"
    t.index ["user_id"], name: "index_interview_assignments_on_user_id"
  end

  create_table "interviews", force: :cascade do |t|
    t.integer "candidate_id", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.datetime "scheduled_end_at"
    t.datetime "scheduled_start_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_interviews_on_candidate_id"
    t.index ["created_by_id"], name: "index_interviews_on_created_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "availabilities", "users"
  add_foreign_key "interview_assignments", "interviews"
  add_foreign_key "interview_assignments", "users"
  add_foreign_key "interviews", "candidates"
  add_foreign_key "interviews", "users", column: "created_by_id"
end
