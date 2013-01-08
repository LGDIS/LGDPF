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

ActiveRecord::Schema.define(:version => 20121211032200) do

  create_table "constants", :force => true do |t|
    t.string   "kind1"
    t.string   "kind2"
    t.string   "kind3"
    t.string   "text"
    t.string   "value"
    t.integer  "_order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "notes", :force => true do |t|
    t.string   "note_record_id"
    t.integer  "person_record_id"
    t.string   "liked_person_record_id"
    t.datetime "entry_date"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_phone"
    t.datetime "source_date"
    t.boolean  "author_made_contact"
    t.integer  "status"
    t.string   "email_of_found_person"
    t.string   "phone_of_found_person"
    t.string   "last_known_location"
    t.text     "text"
    t.string   "photo_url"
    t.boolean  "spam_flag"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "person_record_id"
    t.datetime "entry_date"
    t.datetime "expiry_date"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_phone"
    t.string   "source_name"
    t.datetime "source_date"
    t.string   "source_url"
    t.string   "full_name"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "alternate_names"
    t.text     "description"
    t.integer  "sex"
    t.date     "date_of_birth"
    t.string   "age"
    t.string   "home_street"
    t.string   "home_neighborhood"
    t.string   "home_city"
    t.string   "home_state"
    t.string   "home_postal_code"
    t.string   "home_country"
    t.string   "photo_url"
    t.integer  "public_flag"
    t.integer  "in_city_flag"
    t.string   "shelter_name"
    t.integer  "refuge_status"
    t.string   "refuge_reason"
    t.date     "shelter_entry_date"
    t.date     "shelter_leave_date"
    t.string   "next_place"
    t.string   "next_place_phone"
    t.integer  "injury_flag"
    t.string   "injury_condition"
    t.integer  "allergy_flag"
    t.string   "allergy_cause"
    t.integer  "pregnancy"
    t.integer  "baby"
    t.integer  "upper_care_level_three"
    t.integer  "elderly_alone"
    t.integer  "elderly_couple"
    t.integer  "bedridden_elderly"
    t.integer  "elderly_dementia"
    t.integer  "rehabilitation_certificate"
    t.integer  "physical_disability_certificate"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  set_column_comment 'notes', 'person_record_id', '避難者情報との外部キー'
  set_column_comment 'notes', 'liked_person_record_id', '重複キー'
  set_column_comment 'notes', 'entry_date', '登録日'
  set_column_comment 'notes', 'author_name', '投稿者'
  set_column_comment 'notes', 'author_email', '投稿者のメールアドレス'
  set_column_comment 'notes', 'author_phone', '投稿者の電話番号'
  set_column_comment 'notes', 'source_date', '作成日時'
  set_column_comment 'notes', 'author_made_contact', '連絡の有無'
  set_column_comment 'notes', 'status', '状況'
  set_column_comment 'notes', 'email_of_found_person', '避難者のメールアドレス'
  set_column_comment 'notes', 'phone_of_found_person', '避難者の電話番号'
  set_column_comment 'notes', 'last_known_location', '最後に見かけた場所'
  set_column_comment 'notes', 'text', 'メッセージ'
  set_column_comment 'notes', 'photo_url', '写真のURL'
  set_column_comment 'notes', 'spam_flag', 'スパムフラグ'

  set_column_comment 'people', 'person_record_id', 'id'
  set_column_comment 'people', 'entry_date', 'レコード作成日時'
  set_column_comment 'people', 'expiry_date', 'レコード削除予定日時'
  set_column_comment 'people', 'author_name', 'レコード作成者名'
  set_column_comment 'people', 'author_email', 'レコード作成者のメールアドレス'
  set_column_comment 'people', 'author_phone', 'レコード作成者の電話番号'
  set_column_comment 'people', 'source_name', '情報元のサイト名'
  set_column_comment 'people', 'source_date', '情報元の投稿日'
  set_column_comment 'people', 'source_url', '情報元のサイトURL'
  set_column_comment 'people', 'full_name', '避難者名前'
  set_column_comment 'people', 'given_name', '避難者_名'
  set_column_comment 'people', 'family_name', '避難者_姓'
  set_column_comment 'people', 'alternate_names', '避難者_よみがな'
  set_column_comment 'people', 'description', '説明'
  set_column_comment 'people', 'sex', '性別'
  set_column_comment 'people', 'date_of_birth', '生年月日'
  set_column_comment 'people', 'age', '年齢'
  set_column_comment 'people', 'home_street', '町名'
  set_column_comment 'people', 'home_neighborhood', '近隣'
  set_column_comment 'people', 'home_city', '市区町村'
  set_column_comment 'people', 'home_state', '都道府県'
  set_column_comment 'people', 'home_postal_code', '郵便番号'
  set_column_comment 'people', 'photo_url', '写真のURL'
  set_column_comment 'people', 'public_flag', '公開フラグ'
  set_column_comment 'people', 'in_city_flag', '市内・市外区分'
  set_column_comment 'people', 'shelter_name', '避難所'
  set_column_comment 'people', 'refuge_status', '避難状況'
  set_column_comment 'people', 'refuge_reason', '避難理由'
  set_column_comment 'people', 'shelter_entry_date', '入所年月日'
  set_column_comment 'people', 'shelter_leave_date', '退所年月日'
  set_column_comment 'people', 'next_place', '退所先'
  set_column_comment 'people', 'next_place_phone', '退所先電話番号'
  set_column_comment 'people', 'injury_flag', '負傷'
  set_column_comment 'people', 'injury_condition', '負傷内容'
  set_column_comment 'people', 'allergy_flag', 'アレルギー'
  set_column_comment 'people', 'allergy_cause', 'アレルギー物質'
  set_column_comment 'people', 'pregnancy', '妊婦'
  set_column_comment 'people', 'baby', '乳幼児'
  set_column_comment 'people', 'upper_care_level_three', '要介護度３以上'
  set_column_comment 'people', 'elderly_alone', '１人暮らしの高齢者'
  set_column_comment 'people', 'elderly_couple', '高齢者世帯'
  set_column_comment 'people', 'bedridden_elderly', '寝たきり高齢者'
  set_column_comment 'people', 'elderly_dementia', '認知症高齢者'
  set_column_comment 'people', 'rehabilitation_certificate', ' 療育手帳所持者'
  set_column_comment 'people', 'physical_disability_certificate', '身体障害者手帳所持者'

end
