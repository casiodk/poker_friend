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

ActiveRecord::Schema.define(version: 20150403185157) do

  create_table "cards", force: :cascade do |t|
    t.string   "suite"
    t.string   "val"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hands", force: :cascade do |t|
    t.string   "uid"
    t.integer  "table_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "button"
  end

  add_index "hands", ["table_id"], name: "index_hands_on_table_id"

  create_table "placements", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "hand_id"
    t.integer  "seat"
    t.integer  "start_chips"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "placements", ["hand_id"], name: "index_placements_on_hand_id"
  add_index "placements", ["player_id"], name: "index_placements_on_player_id"

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tables", force: :cascade do |t|
    t.string   "uid"
    t.integer  "tournament_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "tables", ["tournament_id"], name: "index_tables_on_tournament_id"

  create_table "tickets", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "tournament_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "tickets", ["player_id"], name: "index_tickets_on_player_id"
  add_index "tickets", ["tournament_id"], name: "index_tickets_on_tournament_id"

  create_table "tournaments", force: :cascade do |t|
    t.string   "uid"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "table_max"
  end

end
