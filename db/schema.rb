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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "config", :force => true do |t|
    t.string  "username",         :limit => 64
    t.string  "password",         :limit => 64
    t.string  "shortname",        :limit => 64
    t.string  "transport",        :limit => 16
    t.string  "path"
    t.integer "rate"
    t.string  "output_file_root"
    t.string  "jvm"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "transporter_jobs", :force => true do |t|
    t.string   "state",       :limit => 16
    t.string   "options"
    t.text     "result"
    t.string   "exceptions"
    t.string   "output_file"
    t.string   "type",        :limit => 32
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "job_id"
    t.string   "priority",    :limit => 10, :default => "normal", :null => false
    t.string   "target"
  end

end
