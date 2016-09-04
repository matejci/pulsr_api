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

ActiveRecord::Schema.define(version: 20151201195622) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "postgis"

  create_table "authentication_tokens", force: :cascade do |t|
    t.string   "token"
    t.integer  "user_id"
    t.boolean  "revoked",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "authentication_tokens", ["token"], name: "index_authentication_tokens_on_token", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.string   "token"
    t.integer  "user_id"
    t.boolean  "revoked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "authentications", ["token"], name: "index_authentications_on_token", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "parent_id"
  end

  create_table "categories_tastes", id: false, force: :cascade do |t|
    t.integer "taste_id"
    t.integer "category_id"
  end

  add_index "categories_tastes", ["taste_id", "category_id"], name: "index_categories_tastes_on_taste_id_and_category_id", unique: true, using: :btree

  create_table "categories_venues", id: false, force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "venue_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "categories_venues", ["category_id"], name: "index_categories_venues_on_category_id", using: :btree
  add_index "categories_venues", ["venue_id"], name: "index_categories_venues_on_venue_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "name"
    t.decimal  "latitude",   precision: 10, scale: 6
    t.decimal  "longitude",  precision: 10, scale: 6
    t.float    "radius"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.json     "boundaries"
    t.point    "location"
  end

  add_index "cities", ["name"], name: "index_cities_on_name", using: :btree

  create_table "contact_books", force: :cascade do |t|
    t.integer  "user_id"
    t.json     "contacts_cache", default: []
    t.datetime "last_query"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.json     "device_lists",   default: {}
  end

  add_index "contact_books", ["user_id"], name: "index_contact_books_on_user_id", using: :btree

  create_table "contact_values", force: :cascade do |t|
    t.string   "value"
    t.integer  "value_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "contact_values", ["value"], name: "index_contact_values_on_value", using: :btree
  add_index "contact_values", ["value_type"], name: "index_contact_values_on_value_type", using: :btree

  create_table "contact_values_contacts", id: false, force: :cascade do |t|
    t.integer "contact_id"
    t.integer "contact_value_id"
  end

  add_index "contact_values_contacts", ["contact_id", "contact_value_id"], name: "contact_values_join_index", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "contact_book_id"
    t.datetime "contact_added_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "contacts", ["contact_id"], name: "index_contacts_on_contact_id", using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "event_invitations", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.string   "rsvp"
    t.string   "invitation_key"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "sender"
  end

# Could not dump table "events" because of following StandardError
#   Unknown type 'event_kind' for column 'kind'

  create_table "events_performers", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "performer_id"
  end

  add_index "events_performers", ["event_id", "performer_id"], name: "index_events_performers_on_event_id_and_performer_id", unique: true, using: :btree
  add_index "events_performers", ["event_id"], name: "index_events_performers_on_event_id", using: :btree
  add_index "events_performers", ["performer_id"], name: "index_events_performers_on_performer_id", using: :btree

  create_table "failures", force: :cascade do |t|
    t.string   "name"
    t.json     "data"
    t.string   "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flags", force: :cascade do |t|
    t.integer   "user_id"
    t.integer   "flaggable_id"
    t.string    "flaggable_type"
    t.json      "data",                                                                    default: {}
    t.decimal   "latitude"
    t.decimal   "longitude"
    t.geography "lonlat",         limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime  "created_at",                                                                           null: false
    t.datetime  "updated_at",                                                                           null: false
  end

  add_index "flags", ["lonlat"], name: "index_flags_on_lonlat", using: :gist

  create_table "friend_recommendations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.integer  "reason"
    t.integer  "action"
    t.integer  "status"
    t.datetime "status_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "friend_recommendations", ["user_id", "contact_id"], name: "index_friend_recommendations_on_user_id_and_contact_id", unique: true, using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "friendships", ["recipient_id"], name: "index_friendships_on_recipient_id", using: :btree
  add_index "friendships", ["sender_id"], name: "index_friendships_on_sender_id", using: :btree

  create_table "hashtags", force: :cascade do |t|
    t.string   "name"
    t.string   "city_name"
    t.integer  "period"
    t.integer  "counter",     default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.boolean  "is_username"
  end

  add_index "hashtags", ["name", "city_name", "period", "is_username"], name: "index_hashtags_on_name_and_city_name_and_period_and_is_username", unique: true, using: :btree

  create_table "instagram_places", force: :cascade do |t|
    t.integer "venue_id"
    t.string  "name"
    t.string  "factual_id"
    t.integer "place_id"
  end

  add_index "instagram_places", ["factual_id"], name: "index_instagram_places_on_factual_id", using: :btree
  add_index "instagram_places", ["place_id"], name: "index_instagram_places_on_place_id", using: :btree
  add_index "instagram_places", ["venue_id"], name: "index_instagram_places_on_venue_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "invitable_id"
    t.string   "invitable_type"
    t.integer  "user_id"
    t.integer  "sender_id"
    t.text     "message"
    t.datetime "invite_at"
    t.string   "rsvp"
    t.string   "invitation_key"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "invitations", ["invitable_type", "invitable_id"], name: "index_invitations_on_invitable_type_and_invitable_id", using: :btree
  add_index "invitations", ["sender_id"], name: "index_invitations_on_sender_id", using: :btree
  add_index "invitations", ["user_id"], name: "index_invitations_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.integer  "user_id"
    t.integer  "reason"
    t.integer  "status"
    t.integer  "action"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "notifications", ["object_type", "object_id"], name: "index_notifications_on_object_type_and_object_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "performers", force: :cascade do |t|
    t.string   "eventful_id"
    t.string   "eventful_url"
    t.string   "name"
    t.text     "short_bio"
    t.text     "long_bio"
    t.json     "links"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "images",       default: [],              array: true
    t.datetime "processed_at"
    t.string   "twitter"
    t.json     "data",         default: {}
    t.string   "url"
    t.string   "created_by"
    t.string   "instagram"
    t.integer  "user_id"
  end

  create_table "photo_objects", force: :cascade do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.integer  "photo_id"
    t.string   "source"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "photo_objects", ["object_id"], name: "index_photo_objects_on_object_id", using: :btree
  add_index "photo_objects", ["photo_id", "object_id", "object_type"], name: "No duplicated photos", unique: true, using: :btree
  add_index "photo_objects", ["photo_id"], name: "index_photo_objects_on_photo_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.string    "url"
    t.json      "data",                                                                        default: {}
    t.integer   "venue_id"
    t.integer   "instagram_place_id"
    t.string    "service"
    t.datetime  "created_at",                                                                               null: false
    t.datetime  "updated_at",                                                                               null: false
    t.string    "instagram_id"
    t.integer   "kind"
    t.string    "video_url"
    t.text      "caption"
    t.integer   "event"
    t.integer   "performer"
    t.jsonb     "meta_data",                                                                   default: {}
    t.string    "file_file_name"
    t.string    "file_content_type"
    t.integer   "file_file_size"
    t.datetime  "file_updated_at"
    t.integer   "user_id"
    t.decimal   "latitude"
    t.decimal   "longitude"
    t.geography "lonlat",             limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.integer   "tweet_id"
  end

  add_index "photos", ["instagram_id"], name: "index_photos_on_instagram_id", unique: true, using: :btree
  add_index "photos", ["lonlat"], name: "index_photos_on_lonlat", using: :gist
  add_index "photos", ["venue_id"], name: "index_photos_on_venue_id", using: :btree

  create_table "post_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.text      "body"
    t.integer   "user_id"
    t.integer   "photo_id"
    t.integer   "item_id"
    t.string    "item_type"
    t.integer   "post_type_id"
    t.datetime  "created_at",                                                                            null: false
    t.datetime  "updated_at",                                                                            null: false
    t.decimal   "latitude"
    t.decimal   "longitude"
    t.geography "lonlat",       limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.integer   "source_id"
    t.string    "source_type"
    t.boolean   "is_private",                                                            default: false
  end

  add_index "posts", ["created_at"], name: "index_posts_on_created_at", using: :btree
  add_index "posts", ["item_id"], name: "index_posts_on_item_id", using: :btree
  add_index "posts", ["latitude", "longitude"], name: "index_posts_on_latitude_and_longitude", using: :btree
  add_index "posts", ["lonlat"], name: "index_posts_on_lonlat", using: :gist
  add_index "posts", ["photo_id"], name: "index_posts_on_photo_id", using: :btree
  add_index "posts", ["post_type_id"], name: "index_posts_on_post_type_id", using: :btree

  create_table "t_row", id: false, force: :cascade do |t|
    t.integer  "id"
    t.string   "eventful_id"
    t.string   "eventful_url"
    t.string   "name"
    t.text     "description"
    t.string   "category"
    t.string   "street_address"
    t.string   "city"
    t.string   "region"
    t.string   "zip_code"
    t.string   "country"
    t.string   "time_zone"
    t.decimal  "latitude",          precision: 10, scale: 6
    t.decimal  "longitude",         precision: 10, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "images",                                     array: true
    t.string   "telephone_number"
    t.json     "links"
    t.string   "email"
    t.json     "cuisine"
    t.json     "hours"
    t.string   "factual_id"
    t.string   "short_factual_id"
    t.string   "created_by"
    t.decimal  "factual_rating"
    t.decimal  "factual_price"
    t.datetime "processed_at"
    t.string   "twitter"
    t.json     "data"
    t.string   "url"
    t.decimal  "factual_existence"
    t.datetime "pending_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tag_id"
    t.string   "source"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "tags_tastes", id: false, force: :cascade do |t|
    t.integer "taste_id"
    t.integer "tag_id"
  end

  add_index "tags_tastes", ["taste_id", "tag_id"], name: "index_tags_tastes_on_taste_id_and_tag_id", unique: true, using: :btree

  create_table "taste_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tastes", force: :cascade do |t|
    t.string   "name"
    t.integer  "taste_category_id"
    t.text     "description"
    t.text     "example"
    t.string   "title"
    t.string   "import_string"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "timetables", force: :cascade do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "timetables", ["ends_at"], name: "index_timetables_on_ends_at", using: :btree
  add_index "timetables", ["event_id"], name: "index_timetables_on_event_id", using: :btree
  add_index "timetables", ["starts_at"], name: "index_timetables_on_starts_at", using: :btree

  create_table "tweet_activities", force: :cascade do |t|
    t.integer  "counter"
    t.decimal  "latitude",      precision: 10, scale: 6
    t.decimal  "longitude",     precision: 10, scale: 6
    t.json     "farthest_item"
    t.integer  "level"
    t.json     "boundaries"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "period"
    t.point    "location"
  end

  add_index "tweet_activities", ["period"], name: "index_tweet_activities_on_period", using: :btree

  create_table "tweets", force: :cascade do |t|
    t.json     "data"
    t.decimal  "latitude",   precision: 10, scale: 6
    t.decimal  "longitude",  precision: 10, scale: 6
    t.text     "text"
    t.integer  "city_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.point    "location"
  end

  add_index "tweets", ["city_id"], name: "index_tweets_on_city_id", using: :btree

  create_table "user_actions", force: :cascade do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.integer  "user_id"
    t.string   "action"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "starts_at"
  end

  add_index "user_actions", ["action"], name: "index_user_actions_on_action", using: :btree
  add_index "user_actions", ["object_id"], name: "index_user_actions_on_object_id", using: :btree
  add_index "user_actions", ["user_id"], name: "index_user_actions_on_user_id", using: :btree

  create_table "user_tastes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "taste_id"
    t.float    "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_tastes", ["user_id", "taste_id"], name: "index_user_tastes_on_user_id_and_taste_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password",                              default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                   default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "facebook_id"
    t.string   "facebook_token"
    t.string   "phone_number"
    t.boolean  "notifications"
    t.json     "preferences",                                     default: {}
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.decimal  "hometown_latitude",      precision: 10, scale: 6
    t.decimal  "hometown_longitude",     precision: 10, scale: 6
    t.point    "hometown_location"
    t.boolean  "active",                                          default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["phone_number"], name: "index_users_on_phone_number", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "venues", force: :cascade do |t|
    t.string    "eventful_id"
    t.string    "eventful_url"
    t.string    "name"
    t.text      "description"
    t.string    "category"
    t.string    "street_address"
    t.string    "city"
    t.string    "region"
    t.string    "zip_code"
    t.string    "country"
    t.string    "time_zone"
    t.decimal   "latitude",                                                                   precision: 10, scale: 6
    t.decimal   "longitude",                                                                  precision: 10, scale: 6
    t.datetime  "created_at",                                                                                                       null: false
    t.datetime  "updated_at",                                                                                                       null: false
    t.string    "images",                                                                                              default: [],              array: true
    t.string    "telephone_number"
    t.json      "links"
    t.string    "email"
    t.json      "cuisine"
    t.jsonb     "hours"
    t.string    "factual_id"
    t.string    "short_factual_id"
    t.string    "created_by"
    t.decimal   "factual_rating"
    t.decimal   "factual_price"
    t.datetime  "processed_at"
    t.string    "twitter"
    t.json      "data",                                                                                                default: {}
    t.string    "url"
    t.decimal   "factual_existence"
    t.datetime  "pending_at"
    t.datetime  "instagram_at"
    t.point     "location"
    t.geography "lonlat",            limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.integer   "user_id"
    t.integer   "city_id"
  end

  add_index "venues", ["city"], name: "index_venues_on_city", using: :btree
  add_index "venues", ["eventful_id"], name: "index_venues_on_eventful_id", using: :btree
  add_index "venues", ["factual_id"], name: "index_venues_on_factual_id", using: :btree
  add_index "venues", ["hours"], name: "venues_hours_keys_gin", using: :gin
  add_index "venues", ["latitude", "longitude"], name: "index_venues_on_latitude_and_longitude", using: :btree
  add_index "venues", ["lonlat"], name: "index_venues_on_lonlat", using: :gist
  add_index "venues", ["name"], name: "index_venues_on_name", using: :btree
  add_index "venues", ["region"], name: "index_venues_on_region", using: :btree
  add_index "venues", ["street_address"], name: "index_venues_on_street_address", using: :btree
  add_index "venues", ["user_id"], name: "index_venues_on_user_id", using: :btree
  add_index "venues", ["zip_code"], name: "index_venues_on_zip_code", using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "contact_books", "users"
  add_foreign_key "contacts", "users"
  add_foreign_key "instagram_places", "venues"
end
