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

ActiveRecord::Schema.define(version: 20140818092433) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "commits", force: true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.string   "sha1"
    t.string   "user"
    t.datetime "commit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commits", ["location_id"], name: "index_commits_on_location_id", using: :btree

  create_table "deployments", force: true do |t|
    t.integer  "location_id"
    t.integer  "commit_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deployments", ["commit_id"], name: "index_deployments_on_commit_id", using: :btree
  add_index "deployments", ["location_id"], name: "index_deployments_on_location_id", using: :btree

  create_table "locations", force: true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "branch"
    t.string   "application_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "distance"
    t.integer  "worker_id"
  end

  add_index "locations", ["worker_id"], name: "index_locations_on_worker_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "repository_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
  end

  add_index "projects", ["worker_id"], name: "index_projects_on_worker_id", using: :btree

  create_table "workers", force: true do |t|
    t.string   "job_id"
    t.string   "class_name"
    t.integer  "status"
    t.string   "error_class_name"
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
