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

ActiveRecord::Schema.define(version: 12) do

  create_table "accounts", force: :cascade do |t|
    t.string   "username",   limit: 64, null: false
    t.string   "password",   limit: 64, null: false
    t.string   "shortname",  limit: 64
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "accounts", ["username", "shortname"], name: "index_accounts_on_username_and_shortname", unique: true

  create_table "config", force: :cascade do |t|
    t.string  "username",             limit: 64
    t.string  "password",             limit: 64
    t.string  "shortname",            limit: 64
    t.string  "transport",            limit: 16
    t.string  "path",                 limit: 255
    t.integer "rate"
    t.string  "output_log_directory", limit: 255
    t.string  "jvm",                  limit: 255
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "transporter_jobs", force: :cascade do |t|
    t.string   "state",           limit: 16
    t.string   "options",         limit: 1024
    t.text     "result"
    t.string   "exceptions",      limit: 255
    t.string   "output_log_file", limit: 255
    t.string   "type",            limit: 32
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "job_id"
    t.string   "priority",        limit: 10,   default: "normal", null: false
    t.string   "target",          limit: 255
    t.integer  "account_id"
  end

  add_index "transporter_jobs", ["account_id"], name: "index_transporter_jobs_on_account_id"
  add_index "transporter_jobs", ["created_at"], name: "index_transporter_jobs_on_created_at"
  add_index "transporter_jobs", ["priority"], name: "index_transporter_jobs_on_priority"
  add_index "transporter_jobs", ["state"], name: "index_transporter_jobs_on_state"
  add_index "transporter_jobs", ["target"], name: "index_transporter_jobs_on_target"
  add_index "transporter_jobs", ["type"], name: "index_transporter_jobs_on_type"
  add_index "transporter_jobs", ["updated_at"], name: "index_transporter_jobs_on_updated_at"

end
