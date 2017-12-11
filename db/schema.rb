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

ActiveRecord::Schema.define(version: 20171208020000) do

  create_table "fixed_asset_catalogs", force: true do |t|
    t.string   "code",             limit: 8, null: false
    t.string   "name",                       null: false
    t.string   "measurement_unit"
    t.integer  "years"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fixed_asset_imgs", force: true do |t|
    t.integer  "fa_inventory_detail_id"
    t.integer  "fixed_asset_info_id"
    t.string   "img_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fixed_asset_infos", force: true do |t|
    t.string   "sn"
    t.string   "asset_name"
    t.string   "asset_no",                           null: false
    t.integer  "fixed_asset_catalog_id",             null: false
    t.integer  "relevant_unit_id",       limit: 255
    t.datetime "buy_at"
    t.datetime "use_at"
    t.string   "measurement_unit"
    t.integer  "amount"
    t.float    "sum"
    t.integer  "unit_id",                            null: false
    t.string   "branch"
    t.string   "location"
    t.string   "user"
    t.string   "change_log"
    t.string   "accounting_department"
    t.string   "status"
    t.integer  "print_times"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manage_unit_id"
  end

  create_table "fixed_asset_inventories", force: true do |t|
    t.string   "no"
    t.string   "name"
    t.string   "desc"
    t.string   "status"
    t.integer  "create_user_id"
    t.integer  "create_unit_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "is_lv2_unit",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fixed_asset_inventory_details", force: true do |t|
    t.string   "sn"
    t.string   "asset_name"
    t.string   "asset_no",                                      null: false
    t.integer  "fixed_asset_catalog_id",                        null: false
    t.integer  "relevant_unit_id"
    t.datetime "buy_at"
    t.datetime "use_at"
    t.string   "measurement_unit"
    t.integer  "amount"
    t.float    "sum"
    t.integer  "unit_id",                                       null: false
    t.string   "branch"
    t.string   "location"
    t.string   "user"
    t.string   "change_log"
    t.string   "accounting_department"
    t.string   "asset_status"
    t.integer  "print_times"
    t.integer  "manage_unit_id"
    t.integer  "fixed_asset_inventory_id"
    t.string   "inventory_status"
    t.boolean  "is_check",                      default: false
    t.string   "desc"
    t.integer  "fixed_asset_inventory_unit_id"
    t.integer  "fixed_asset_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fixed_asset_inventory_units", force: true do |t|
    t.integer  "unit_id"
    t.integer  "fixed_asset_inventory_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "low_value_consumption_catalogs", force: true do |t|
    t.string   "code",             limit: 8, null: false
    t.string   "name",                       null: false
    t.string   "measurement_unit"
    t.integer  "years"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "low_value_consumption_infos", force: true do |t|
    t.string   "sn"
    t.string   "asset_name",                    null: false
    t.string   "asset_no"
    t.integer  "lvc_catalog_id",                null: false
    t.integer  "relevant_unit_id"
    t.datetime "buy_at"
    t.datetime "use_at"
    t.string   "measurement_unit"
    t.float    "sum"
    t.integer  "use_unit_id"
    t.string   "branch"
    t.string   "location"
    t.string   "user"
    t.string   "change_log"
    t.string   "status"
    t.integer  "print_times"
    t.string   "brand_model"
    t.string   "batch_no"
    t.integer  "purchase_id"
    t.integer  "manage_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "log",              limit: 4000
    t.datetime "discard_at"
  end

  create_table "lvc_imgs", force: true do |t|
    t.integer  "lvc_inventory_detail_id"
    t.integer  "low_value_consumption_info_id"
    t.string   "img_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lvc_inventories", force: true do |t|
    t.string   "no"
    t.string   "name"
    t.string   "desc"
    t.string   "status"
    t.integer  "create_user_id"
    t.integer  "create_unit_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "is_lv2_unit",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lvc_inventory_details", force: true do |t|
    t.string   "sn"
    t.string   "asset_name",                                    null: false
    t.string   "asset_no"
    t.integer  "lvc_catalog_id",                                null: false
    t.integer  "relevant_unit_id"
    t.datetime "buy_at"
    t.datetime "use_at"
    t.string   "measurement_unit"
    t.float    "sum"
    t.integer  "use_unit_id"
    t.string   "branch"
    t.string   "location"
    t.string   "user"
    t.string   "change_log"
    t.string   "consumption_status"
    t.integer  "print_times"
    t.string   "brand_model"
    t.string   "batch_no"
    t.integer  "purchase_id"
    t.integer  "manage_unit_id"
    t.integer  "lvc_inventory_id"
    t.string   "inventory_status"
    t.boolean  "is_check",                      default: false
    t.string   "desc"
    t.integer  "lvc_inventory_unit_id"
    t.integer  "low_value_consumption_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lvc_inventory_units", force: true do |t|
    t.integer  "unit_id"
    t.integer  "lvc_inventory_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchases", force: true do |t|
    t.string   "no",                                            null: false
    t.string   "name"
    t.string   "status"
    t.integer  "create_user_id"
    t.integer  "create_unit_id"
    t.integer  "manage_unit_id"
    t.boolean  "is_send",                       default: false
    t.integer  "to_check_user_id"
    t.integer  "checked_user_id"
    t.string   "change_log",       limit: 4000
    t.string   "desc"
    t.integer  "use_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "unit_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sequences", force: true do |t|
    t.string   "entity"
    t.integer  "unit_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.string   "no"
    t.string   "short_name"
    t.string   "tcbd_khdh"
    t.integer  "unit_level"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_facility_management_unit", default: false
  end

  add_index "units", ["name"], name: "index_units_on_name", unique: true

  create_table "user_logs", force: true do |t|
    t.integer  "user_id",            default: 0,  null: false
    t.string   "operation",          default: "", null: false
    t.string   "object_class"
    t.integer  "object_primary_key"
    t.string   "object_symbol"
    t.string   "desc"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username",               default: "", null: false
    t.string   "role",                   default: "", null: false
    t.string   "name"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
