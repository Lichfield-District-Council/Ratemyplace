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

ActiveRecord::Schema.define(:version => 20120403094253) do

  create_table "addresses", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contacts", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "councils", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "fsaid"
    t.text     "address"
    t.text     "tel"
    t.text     "fax"
    t.text     "email"
    t.text     "logo"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "snac"
    t.string   "slug"
  end

  add_index "councils", ["id"], :name => "index_councils_on_id"
  add_index "councils", ["slug"], :name => "index_councils_on_slug", :unique => true

  create_table "inspections", :force => true do |t|
    t.string   "name",                                   :null => false
    t.text     "address1",                               :null => false
    t.text     "address2"
    t.text     "address3"
    t.text     "address4"
    t.text     "town",                                   :null => false
    t.text     "postcode",                               :null => false
    t.text     "operator"
    t.text     "uprn"
    t.string   "tel"
    t.text     "category",                               :null => false
    t.text     "scope",                                  :null => false
    t.integer  "hygiene",                                :null => false
    t.integer  "structure",                              :null => false
    t.integer  "confidence",                             :null => false
    t.integer  "rating",                                 :null => false
    t.string   "image"
    t.string   "report"
    t.boolean  "tradingstandards"
    t.boolean  "healthy"
    t.string   "email"
    t.string   "website"
    t.text     "hours"
    t.date     "date"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "councilid"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "report_file_name"
    t.string   "report_content_type"
    t.integer  "report_file_size"
    t.datetime "report_updated_at"
    t.string   "menu_file_name"
    t.string   "menu_content_type"
    t.integer  "menu_file_size"
    t.datetime "menu_updated_at"
    t.string   "slug"
    t.boolean  "published",           :default => false
    t.string   "internalid"
    t.date     "appealdate"
    t.boolean  "appeal"
    t.boolean  "revisit_requested"
  end

  add_index "inspections", ["id"], :name => "index_inspections_on_id"
  add_index "inspections", ["slug"], :name => "index_inspections_on_slug", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "tag"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "inspection_id"
  end

  create_table "uploads", :force => true do |t|
    t.string   "name"
    t.string   "report_file_name"
    t.string   "report_content_type"
    t.integer  "report_file_size"
    t.datetime "report_updated_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "councilid"
  end

end
