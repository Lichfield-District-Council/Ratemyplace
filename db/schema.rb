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

ActiveRecord::Schema.define(:version => 20120510133417) do

  create_table "addresses", :force => true do |t|
    t.text     "uprn",             :limit => 255
    t.text     "organisation",     :limit => 255
    t.integer  "sao_start"
    t.text     "sao_start_suffix", :limit => 255
    t.integer  "sao_end"
    t.text     "sao_end_suffix",   :limit => 255
    t.text     "sao_text",         :limit => 255
    t.integer  "pao_start"
    t.text     "pao_start_suffix", :limit => 255
    t.integer  "pao_end"
    t.text     "pao_end_suffix",   :limit => 255
    t.text     "pao_text",         :limit => 255
    t.text     "street",           :limit => 255
    t.text     "town",             :limit => 255
    t.text     "locality",         :limit => 255
    t.text     "county",           :limit => 255
    t.text     "postcode",         :limit => 255
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.text     "fulladdress",      :limit => 2147483647
  end

  add_index "addresses", ["fulladdress"], :name => "fulladdress"

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
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "snac"
    t.string   "slug"
    t.string   "username"
    t.string   "password"
    t.boolean  "external",   :default => true
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
    t.string   "tel",                 :default => ""
    t.text     "category",                               :null => false
    t.text     "scope",                                  :null => false
    t.integer  "hygiene",                                :null => false
    t.integer  "structure",                              :null => false
    t.integer  "confidence",                             :null => false
    t.integer  "rating",                                 :null => false
    t.string   "imageold"
    t.string   "reportold"
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
    t.boolean  "appeal",              :default => false
    t.boolean  "revisit_requested"
    t.string   "foursquare_id"
    t.string   "foursquare_tip_id"
    t.integer  "annex5"
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
