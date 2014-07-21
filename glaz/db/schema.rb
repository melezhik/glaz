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

ActiveRecord::Schema.define(version: 20140721114052) do

  create_table "builds", force: true do |t|
    t.string   "state"
    t.text     "value"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
  end

  add_index "builds", ["task_id"], name: "index_builds_on_task_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "hosts", force: true do |t|
    t.string   "title"
    t.string   "fqdn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",    default: true
  end

  create_table "logs", force: true do |t|
    t.string   "level"
    t.binary   "chunk",      limit: 16777215
    t.integer  "build_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logs", ["build_id"], name: "index_logs_on_build_id", using: :btree

  create_table "metrics", force: true do |t|
    t.string   "title"
    t.string   "command"
    t.string   "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "command_type",  default: "ssh"
  end

  create_table "submetrics", force: true do |t|
    t.integer  "sub_metric_id"
    t.integer  "metric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submetrics", ["metric_id"], name: "index_sub_metrics_on_metric_id", using: :btree

  create_table "tasks", force: true do |t|
    t.integer "host_id"
    t.integer "metric_id"
    t.boolean "enabled",   default: true
  end

end
