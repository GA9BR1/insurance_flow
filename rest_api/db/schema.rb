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

ActiveRecord::Schema[7.1].define(version: 2024_03_18_192939) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "policy_status", ["emited", "waiting_payment", "canceled"]

  create_table "insureds", force: :cascade do |t|
    t.string "name"
    t.string "cpf"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "policies", force: :cascade do |t|
    t.date "issue_date"
    t.date "coverage_end"
    t.bigint "insured_id", null: false
    t.bigint "vehicle_id", null: false
    t.enum "status", default: "waiting_payment", null: false, enum_type: "policy_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insured_id"], name: "index_policies_on_insured_id"
    t.index ["vehicle_id"], name: "index_policies_on_vehicle_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "brand"
    t.string "model"
    t.string "year"
    t.string "plate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "policies", "insureds"
  add_foreign_key "policies", "vehicles"
end
