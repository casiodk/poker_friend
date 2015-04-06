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

ActiveRecord::Schema.define(version: 20150406171801) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.integer  "placement_id"
    t.integer  "round_id"
    t.string   "action"
    t.string   "action_txt"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "amount"
  end

  add_index "actions", ["placement_id"], name: "index_actions_on_placement_id", using: :btree
  add_index "actions", ["round_id"], name: "index_actions_on_round_id", using: :btree

  create_table "cards", force: :cascade do |t|
    t.string   "suite"
    t.string   "val"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "placement_id"
  end

  add_index "cards", ["placement_id"], name: "index_cards_on_placement_id", using: :btree

  create_table "hands", force: :cascade do |t|
    t.string   "uid"
    t.integer  "table_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "button"
  end

  add_index "hands", ["table_id"], name: "index_hands_on_table_id", using: :btree
  add_index "hands", ["uid"], name: "index_hands_on_uid", using: :btree

  create_table "placements", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "hand_id"
    t.integer  "seat"
    t.integer  "start_chips"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "placements", ["hand_id"], name: "index_placements_on_hand_id", using: :btree
  add_index "placements", ["player_id"], name: "index_placements_on_player_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.integer  "hand_id"
    t.string   "stage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "position"
  end

  add_index "rounds", ["hand_id"], name: "index_rounds_on_hand_id", using: :btree
  add_index "rounds", ["position"], name: "index_rounds_on_position", using: :btree

  create_table "tables", force: :cascade do |t|
    t.string   "uid"
    t.integer  "tournament_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "tables", ["tournament_id"], name: "index_tables_on_tournament_id", using: :btree
  add_index "tables", ["uid"], name: "index_tables_on_uid", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "tournament_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "tickets", ["player_id"], name: "index_tickets_on_player_id", using: :btree
  add_index "tickets", ["tournament_id"], name: "index_tickets_on_tournament_id", using: :btree

  create_table "tournaments", force: :cascade do |t|
    t.string   "uid"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "table_max"
  end

  add_index "tournaments", ["uid"], name: "index_tournaments_on_uid", using: :btree

  add_foreign_key "actions", "placements"
  add_foreign_key "actions", "rounds"
  add_foreign_key "cards", "placements"
  add_foreign_key "hands", "tables"
  add_foreign_key "placements", "hands"
  add_foreign_key "placements", "players"
  add_foreign_key "rounds", "hands"
  add_foreign_key "tables", "tournaments"
  add_foreign_key "tickets", "players"
  add_foreign_key "tickets", "tournaments"
end
