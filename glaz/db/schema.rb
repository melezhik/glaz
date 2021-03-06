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

ActiveRecord::Schema.define(version: 20141120150306) do

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",                    default: 0, null: false
    t.integer  "attempts",                    default: 0, null: false
    t.text     "handler",    limit: 16777215,             null: false
    t.text     "last_error", limit: 16777215
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

  create_table "images", force: true do |t|
    t.boolean  "keep_me",     default: false
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "layout_type", default: "table"
    t.binary   "raw_data"
    t.binary   "handler"
  end

  add_index "images", ["report_id"], name: "index_images_on_report_id", using: :btree

  create_table "logs", force: true do |t|
    t.string   "level"
    t.binary   "chunk",      limit: 16777215
    t.integer  "build_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stat_id"
  end

  add_index "logs", ["build_id"], name: "index_logs_on_build_id", using: :btree
  add_index "logs", ["stat_id"], name: "index_logs_on_stat_id", using: :btree

  create_table "metrics", force: true do |t|
    t.string   "title"
    t.text     "command"
    t.string   "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "command_type",  default: "ssh"
    t.binary   "handler"
    t.boolean  "verbose",       default: false
    t.string   "name"
  end

  create_table "points", force: true do |t|
    t.integer "host_id"
    t.integer "report_id"
  end

  create_table "reports", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "layout_type", default: "table"
    t.binary   "handler"
  end

  create_table "sindices", force: true do |t|
    t.integer  "stat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "host_id"
    t.integer  "report_id"
    t.integer  "metric_id"
  end

  create_table "stats", force: true do |t|
    t.binary   "value",      limit: 2147483647
    t.integer  "metric_id"
    t.integer  "timestamp"
    t.integer  "host_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "task_id"
    t.integer  "image_id"
    t.string   "status",                        default: "PENDING"
    t.boolean  "deviated",                      default: false
    t.integer  "duration"
    t.integer  "index_id"
  end

  add_index "stats", ["image_id"], name: "index_stats_on_images_id", using: :btree
  add_index "stats", ["metric_id"], name: "index_stats_on_metric_id", using: :btree
  add_index "stats", ["task_id"], name: "index_stats_on_task_id", using: :btree

  create_table "subhosts", force: true do |t|
    t.integer  "host_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_host_id"
  end

  add_index "subhosts", ["host_id"], name: "index_subhosts_on_host_id", using: :btree

  create_table "submetrics", force: true do |t|
    t.integer  "sub_metric_id"
    t.integer  "metric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submetrics", ["metric_id"], name: "index_sub_metrics_on_metric_id", using: :btree

  create_table "tags", force: true do |t|
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["report_id"], name: "index_tags_on_report_id", using: :btree

  create_table "tasks", force: true do |t|
    t.integer "host_id"
    t.integer "metric_id"
    t.boolean "enabled",      default: true
    t.string  "fqdn"
    t.text    "command"
    t.string  "command_type"
    t.binary  "handler"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.integer  "roles_mask"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "xpoints", force: true do |t|
    t.integer "metric_id"
    t.integer "report_id"
  end

end
