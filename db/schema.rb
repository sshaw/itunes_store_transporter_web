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

ActiveRecord::Schema.define(version: 19) do

  create_table "accounts", force: :cascade do |t|
    t.string   "username",             limit: 64,                 null: false
    t.string   "password",             limit: 64,                 null: false
    t.string   "shortname",            limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alias",                limit: 32
    t.boolean  "disable_notification",            default: false, null: false
  end

  add_index "accounts", ["alias"], name: "index_accounts_on_alias", unique: true
  add_index "accounts", ["username", "shortname"], name: "index_accounts_on_username_and_shortname", unique: true

  create_table "config", force: :cascade do |t|
    t.string  "username",               limit: 64
    t.string  "password",               limit: 64
    t.string  "shortname",              limit: 64
    t.string  "transport",              limit: 16
    t.string  "path"
    t.integer "rate"
    t.string  "output_log_directory"
    t.string  "jvm"
    t.time    "check_upload_status_at"
    t.string  "smtp_host"
    t.integer "smtp_port"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "name",       limit: 32,  null: false
    t.string   "from",       limit: 64,  null: false
    t.string   "to",         limit: 128, null: false
    t.string   "subject",    limit: 128, null: false
    t.string   "reply_to",   limit: 64
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",             null: false
  end

  add_index "notifications", ["account_id"], name: "index_notifications_on_account_id", unique: true

  create_table "packages", force: :cascade do |t|
    t.string   "title",                        null: false
    t.string   "vendor_id",         limit: 64, null: false
    t.string   "current_status",    limit: 32
    t.datetime "last_upload"
    t.datetime "last_status_check"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",                   null: false
  end

  add_index "packages", ["current_status"], name: "index_packages_on_current_status"
  add_index "packages", ["last_status_check"], name: "index_packages_on_last_status_check"
  add_index "packages", ["last_upload"], name: "index_packages_on_last_upload"
  add_index "packages", ["updated_at"], name: "index_packages_on_updated_at"
  add_index "packages", ["vendor_id"], name: "index_packages_on_vendor_id", unique: true

  create_table "statuses", force: :cascade do |t|
    t.string   "name",       limit: 32, null: false
    t.datetime "time",                  null: false
    t.integer  "package_id",            null: false
  end

  create_table "transporter_jobs", force: :cascade do |t|
    t.string   "state",                limit: 16
    t.string   "options",              limit: 1024
    t.text     "result"
    t.text     "exceptions"
    t.string   "output_log_file"
    t.string   "type",                 limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id"
    t.string   "priority",             limit: 10,   default: "normal", null: false
    t.string   "target"
    t.integer  "account_id"
    t.boolean  "disable_notification",              default: false,    null: false
    t.text     "vendor_ids"
  end

  add_index "transporter_jobs", ["account_id"], name: "index_transporter_jobs_on_account_id"
  add_index "transporter_jobs", ["created_at"], name: "index_transporter_jobs_on_created_at"
  add_index "transporter_jobs", ["priority"], name: "index_transporter_jobs_on_priority"
  add_index "transporter_jobs", ["state"], name: "index_transporter_jobs_on_state"
  add_index "transporter_jobs", ["target"], name: "index_transporter_jobs_on_target"
  add_index "transporter_jobs", ["type"], name: "index_transporter_jobs_on_type"
  add_index "transporter_jobs", ["updated_at"], name: "index_transporter_jobs_on_updated_at"

end
