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

ActiveRecord::Schema.define(:version => 0) do

  create_table "archive", :primary_key => "ListingId", :force => true do |t|
    t.string   "Name",        :limit => 128
    t.string   "Seller",      :limit => 24
    t.integer  "SellerId",                                                 :default => 0,   :null => false
    t.string   "Buyer",       :limit => 24
    t.integer  "BuyerId",                                                  :default => 0,   :null => false
    t.datetime "EndDate",                                                                   :null => false
    t.decimal  "Value",                      :precision => 7, :scale => 2
    t.decimal  "Buynow",                     :precision => 7, :scale => 2, :default => 0.0
    t.integer  "ReserveMet",  :limit => 1,                                 :default => 0,   :null => false
    t.integer  "BidCnt",      :limit => 2
    t.text     "Description",                                                               :null => false
    t.string   "ListingURL",  :limit => 256
    t.string   "PhotoURL",    :limit => 256
    t.integer  "SkipIt",      :limit => 1,                                 :default => 0
    t.integer  "Attention",   :limit => 1,                                 :default => 0
    t.integer  "TimeStamp"
    t.integer  "NewBuynow",   :limit => 1
    t.integer  "Repeated",    :limit => 1
  end

  add_index "archive", ["Name", "Seller", "Value"], :name => "Search"

  create_table "bidders", :primary_key => "Bidder", :force => true do |t|
    t.integer "Pro",    :limit => 1, :null => false
    t.integer "Exp",                 :null => false
    t.integer "Bought", :limit => 1, :null => false
  end

  create_table "bids", :id => false, :force => true do |t|
    t.integer "ListingId",                               :null => false
    t.integer "User",                                    :null => false
    t.decimal "Value",     :precision => 7, :scale => 2, :null => false
  end

  add_index "bids", ["ListingId"], :name => "Listing"
  add_index "bids", ["User"], :name => "User"

  create_table "lists", :primary_key => "ListingId", :force => true do |t|
    t.string   "Name",        :limit => 128
    t.string   "Seller",      :limit => 24
    t.integer  "SellerId",                                                                  :null => false
    t.datetime "EndDate",                                                                   :null => false
    t.decimal  "Value",                      :precision => 7, :scale => 2
    t.decimal  "Buynow",                     :precision => 7, :scale => 2, :default => 0.0
    t.integer  "ReserveMet",  :limit => 1,                                 :default => 0,   :null => false
    t.integer  "BidCnt",      :limit => 2
    t.integer  "BuyerId",                                                  :default => 0,   :null => false
    t.text     "Description",                                                               :null => false
    t.string   "ListingURL",  :limit => 256
    t.string   "PhotoURL",    :limit => 256
    t.integer  "SkipIt",      :limit => 1,                                 :default => 0
    t.integer  "Attention",   :limit => 1,                                 :default => 0
    t.integer  "TimeStamp"
    t.integer  "NewBuynow",   :limit => 1,                                 :default => 0,   :null => false
    t.integer  "Repeated",    :limit => 1,                                 :default => 0,   :null => false
  end

  create_table "oauth", :primary_key => "oauth_token", :force => true do |t|
    t.string  "oauth_token_secret",       :limit => 34
    t.string  "oauth_callback_confirmed", :limit => 5
    t.string  "oauth_token_type",         :limit => 8
    t.integer "oauth_token_time"
    t.string  "consumer_key",             :limit => 34
    t.string  "consumer_secret",          :limit => 34
  end

  create_table "sellers", :primary_key => "Seller", :force => true do |t|
    t.integer "Sold"
    t.integer "Listed",              :null => false
    t.integer "Good",   :limit => 1
    t.integer "Bad",    :limit => 1
  end

  create_table "tokens", :id => false, :force => true do |t|
    t.string  "oauth_token",              :limit => 34, :default => "", :null => false
    t.string  "oauth_token_secret",       :limit => 34
    t.string  "oauth_callback_confirmed", :limit => 5
    t.string  "oauth_token_type",         :limit => 8
    t.integer "oauth_token_time"
    t.string  "consumer_key",             :limit => 34
    t.string  "consumer_secret",          :limit => 34
  end

  create_table "users", :primary_key => "Id", :force => true do |t|
    t.string  "Name",         :limit => 128
    t.integer "Exp",                                        :null => false
    t.integer "Bought",                      :default => 0, :null => false
    t.integer "Sold",                        :default => 0, :null => false
    t.integer "Listed",                      :default => 0, :null => false
    t.integer "Rated",        :limit => 1,   :default => 0, :null => false
    t.integer "BuyerRating",  :limit => 1,   :default => 0, :null => false
    t.integer "SellerRating", :limit => 1,   :default => 0, :null => false
  end

  add_index "users", ["Name"], :name => "name"

end
