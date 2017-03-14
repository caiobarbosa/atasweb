# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160814220328) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "health_plans", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "health_plan_id"
    t.integer  "supply_area_id"
    t.string   "order_number"
    t.integer  "o2_prescription"
    t.integer  "period"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "patients", ["health_plan_id"], name: "index_patients_on_health_plan_id", using: :btree
  add_index "patients", ["supply_area_id"], name: "index_patients_on_supply_area_id", using: :btree
  add_index "patients", ["user_id"], name: "index_patients_on_user_id", using: :btree

  create_table "pressures", force: :cascade do |t|
    t.decimal  "value"
    t.integer  "sensor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal  "spent"
  end

  add_index "pressures", ["sensor_id"], name: "index_pressures_on_sensor_id", using: :btree

  create_table "sensors", force: :cascade do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.decimal  "capacity"
    t.integer  "patient_id"
  end

  add_index "sensors", ["patient_id"], name: "index_sensors_on_patient_id", using: :btree
  add_index "sensors", ["user_id"], name: "index_sensors_on_user_id", using: :btree

  create_table "supply_areas", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "temperature_sensors", force: :cascade do |t|
    t.string   "name"
    t.string   "token"
    t.integer  "sensor_kind"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "temperature_sensors", ["user_id"], name: "index_temperature_sensors_on_user_id", using: :btree

  create_table "temperatures", force: :cascade do |t|
    t.decimal  "value"
    t.decimal  "humidity"
    t.integer  "status_door"
    t.integer  "temperature_sensor_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "temperatures", ["temperature_sensor_id"], name: "index_temperatures_on_temperature_sensor_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "patients", "health_plans"
  add_foreign_key "patients", "supply_areas"
  add_foreign_key "patients", "users"
  add_foreign_key "pressures", "sensors"
  add_foreign_key "sensors", "patients"
  add_foreign_key "sensors", "users"
  add_foreign_key "temperature_sensors", "users"
  add_foreign_key "temperatures", "temperature_sensors"
end
