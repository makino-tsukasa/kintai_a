# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20191220013957) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.datetime "expecting_finish_time"
    t.text "details_of_tasks"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.integer "request_to"
    t.datetime "redesignated_endtime"
    t.datetime "first_started_at"
    t.datetime "first_finished_at"
    t.datetime "request_started_at"
    t.datetime "request_finished_at"
    t.integer "oneday_attendance_request_to"
    t.integer "oneday_attendance_status"
    t.datetime "date_of_approvement"
    t.integer "monthly_approvement_status"
    t.integer "monthly_approvement_to"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number"
    t.string "base_name"
    t.string "type_of_attendance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.boolean "superior", default: false
    t.datetime "basic_work_time", default: "2019-12-23 23:00:00"
    t.datetime "designated_work_start_time", default: "2019-12-24 01:00:00"
    t.datetime "designated_work_end_time", default: "2019-12-24 10:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
