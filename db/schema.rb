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

ActiveRecord::Schema.define(version: 20140707141118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "commits", force: true do |t|
    t.integer  "deployment_id"
    t.string   "name"
    t.string   "sha1"
    t.string   "user"
    t.date     "commit_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commits", ["deployment_id"], name: "index_commits_on_deployment_id", using: :btree

  create_table "deployments", force: true do |t|
    t.integer  "project_id"
    t.integer  "environment_id"
    t.string   "state"
    t.date     "finish_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deployments", ["environment_id"], name: "index_deployments_on_environment_id", using: :btree
  add_index "deployments", ["project_id"], name: "index_deployments_on_project_id", using: :btree

  create_table "environments", force: true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "branch"
    t.string   "application_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "environments", ["project_id"], name: "index_environments_on_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "repository_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
