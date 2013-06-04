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

ActiveRecord::Schema.define(:version => 20130521073112) do



  create_table "api_action_logs", :force => true do |t|
    t.string   "unique_key"
    t.datetime "entry_date"
  end

  create_table "cities", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "country_codes", :force => true do |t|
    t.string "name"
    t.string "code"
  end

  create_table "notes", :force => true do |t|
    t.string   "note_record_id",          :limit => 500
    t.integer  "person_record_id"
    t.string   "linked_person_record_id", :limit => 500
    t.datetime "entry_date"
    t.string   "author_name",             :limit => 500
    t.string   "author_email",            :limit => 500
    t.string   "author_phone",            :limit => 500
    t.datetime "source_date"
    t.boolean  "author_made_contact",                    :default => false
    t.integer  "status"
    t.string   "email_of_found_person",   :limit => 500
    t.string   "phone_of_found_person",   :limit => 500
    t.string   "last_known_location",     :limit => 500
    t.text     "text"
    t.string   "photo_url",               :limit => 500
    t.boolean  "spam_flag"
    t.boolean  "link_flag",                              :default => false
    t.boolean  "email_flag",                             :default => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "person_record_id",                :limit => 500
    t.datetime "entry_date"
    t.datetime "expiry_date"
    t.string   "author_name",                     :limit => 500
    t.string   "author_email",                    :limit => 500
    t.string   "author_phone",                    :limit => 500
    t.string   "source_name",                     :limit => 500
    t.datetime "source_date"
    t.string   "source_url",                      :limit => 500
    t.string   "full_name",                       :limit => 500
    t.string   "given_name",                      :limit => 500
    t.string   "family_name",                     :limit => 500
    t.string   "alternate_names",                 :limit => 500
    t.text     "description"
    t.string   "sex",                             :limit => 1
    t.date     "date_of_birth"
    t.string   "age",                             :limit => 500
    t.string   "home_street",                     :limit => 500
    t.string   "home_neighborhood",               :limit => 500
    t.string   "home_city",                       :limit => 500
    t.string   "home_state",                      :limit => 500
    t.string   "home_postal_code",                :limit => 500
    t.string   "home_country",                    :limit => 500
    t.string   "photo_url",                       :limit => 500
    t.string   "profile_urls",                    :limit => 500
    t.integer  "public_flag"
    t.string   "in_city_flag",                    :limit => 1
    t.string   "shelter_name",                    :limit => 20
    t.string   "refuge_status",                   :limit => 1
    t.text     "refuge_reason"
    t.date     "shelter_entry_date"
    t.date     "shelter_leave_date"
    t.string   "next_place",                      :limit => 100
    t.string   "next_place_phone",                :limit => 20
    t.string   "injury_flag",                     :limit => 1
    t.text     "injury_condition"
    t.string   "allergy_flag",                    :limit => 1
    t.text     "allergy_cause"
    t.string   "pregnancy",                       :limit => 1
    t.string   "baby",                            :limit => 1
    t.string   "upper_care_level_three",          :limit => 2
    t.string   "elderly_alone",                   :limit => 1
    t.string   "elderly_couple",                  :limit => 1
    t.string   "bedridden_elderly",               :limit => 1
    t.string   "elderly_dementia",                :limit => 1
    t.string   "rehabilitation_certificate",      :limit => 2
    t.string   "physical_disability_certificate", :limit => 1
    t.string   "family_well",                     :limit => 1
    t.boolean  "link_flag",                                      :default => false
    t.boolean  "notes_disabled",                                 :default => false
    t.boolean  "email_flag",                                     :default => false
    t.boolean  "export_flag",                                    :default => false
    t.datetime "deleted_at"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shelters", :force => true do |t|
    t.string   "name"
    t.string   "name_kana"
    t.string   "area"
    t.string   "address"
    t.string   "phone"
    t.string   "fax"
    t.string   "e_mail"
    t.string   "person_responsible"
    t.string   "shelter_type"
    t.string   "shelter_type_detail"
    t.string   "shelter_sort"
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.integer  "capacity"
    t.string   "status"
    t.integer  "head_count"
    t.integer  "head_count_voluntary"
    t.integer  "households"
    t.integer  "households_voluntary"
    t.datetime "checked_at"
    t.string   "shelter_code"
    t.string   "manager_code"
    t.string   "manager_name"
    t.string   "manager_another_name"
    t.datetime "reported_at"
    t.string   "building_damage_info"
    t.string   "electric_infra_damage_info"
    t.string   "communication_infra_damage_info"
    t.string   "other_damage_info"
    t.string   "usable_flag"
    t.string   "openable_flag"
    t.integer  "injury_count"
    t.integer  "upper_care_level_three_count"
    t.integer  "elderly_alone_count"
    t.integer  "elderly_couple_count"
    t.integer  "bedridden_elderly_count"
    t.integer  "elderly_dementia_count"
    t.integer  "rehabilitation_certificate_count"
    t.integer  "physical_disability_certificate_count"
    t.string   "note"
    t.datetime "deleted_at"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "record_mode",                           :default => 0, :null => false
  end

  add_index "shelters", ["name", "record_mode"], :name => "index_shelters_on_name_and_record_mode", :unique => true, :where => "(deleted_at IS NULL)"
  add_index "shelters", ["shelter_code"], :name => "index_shelters_on_shelter_code", :unique => true, :where => "(deleted_at IS NULL)"

  create_table "streets", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "person_record_id"
    t.string   "author_email",     :limit => 500
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  set_column_comment 'api_action_logs', 'unique_key', 'ユニークキー'
  set_column_comment 'api_action_logs', 'entry_date', '作成日時'

  set_column_comment 'cities', 'id', 'ID'
  set_column_comment 'cities', 'code', '市区町村コード'
  set_column_comment 'cities', 'name', '市区町村名'

  set_column_comment 'country_codes', 'name', '国名'
  set_column_comment 'country_codes', 'code', '国別コード'

  set_column_comment 'notes', 'id', 'このレコードのプライマリ ID'
  set_column_comment 'notes', 'note_record_id', 'このメモ情報の一意の ID（RFC4122 UUID）'
  set_column_comment 'notes', 'person_record_id', 'このメモ情報が紐づく対象者情報への外部キー'
  set_column_comment 'notes', 'linked_person_record_id', 'このメモ情報が紐づく重複した対象者情報への外部キー'
  set_column_comment 'notes', 'entry_date', 'このメモ情報の作成日時'
  set_column_comment 'notes', 'author_name', 'このメモ情報の作成者名'
  set_column_comment 'notes', 'author_email', 'このメモ情報の作成者の電子メールアドレス'
  set_column_comment 'notes', 'author_phone', 'このメモ情報の作成者の電話番号'
  set_column_comment 'notes', 'source_date', 'このメモ情報の情報元におけるメモ情報の投稿日'
  set_column_comment 'notes', 'author_made_contact', 'このメモ情報の作成者がこのメモ情報が紐づく対象者と連絡がとれた場合を True とするフラグ'
  set_column_comment 'notes', 'status', 'このメモが表す状況区分'
  set_column_comment 'notes', 'email_of_found_person', 'このメモ情報が紐づく対象者の現在の電子メールアドレス'
  set_column_comment 'notes', 'phone_of_found_person', 'このメモ情報が紐づく対象者の現在の電話番号'
  set_column_comment 'notes', 'last_known_location', 'このメモ情報が紐づく対象者を最後に見かけた場所'
  set_column_comment 'notes', 'text', 'このメモのメッセージ'
  set_column_comment 'notes', 'photo_url', 'このメモに関連する写真への URL'
  set_column_comment 'notes', 'spam_flag', 'このメモ情報がスパムである場合を True とするフラグ'
  set_column_comment 'notes', 'link_flag', 'このメモ情報を LGDPF/LGDPM 以外の安否確認システムとの間で連携することを、メモ情報の作成者が許容する場合を True とするフラグ'
  set_column_comment 'notes', 'email_flag', 'このメモに関連する情報に変化が生じた場合にメッセージを送る事を、メモ情報の作成者が希望する場合を True とするフラグ'
  set_column_comment 'notes', 'created_at', 'このレコードの作成日時'
  set_column_comment 'notes', 'updated_at', 'このレコードの更新日時'

  set_column_comment 'people', 'id', 'このレコードのプライマリ ID'
  set_column_comment 'people', 'person_record_id', 'この対象者情報の一意の ID（RFC4122 UUID）'
  set_column_comment 'people', 'entry_date', 'この対象者情報の作成日時'
  set_column_comment 'people', 'expiry_date', 'この対象者情報の削除予定日時'
  set_column_comment 'people', 'author_name', 'この対象者情報の作成者名'
  set_column_comment 'people', 'author_email', 'この対象者情報の作成者の電子メールアドレス'
  set_column_comment 'people', 'author_phone', 'この対象者情報の作成者の電話番号'
  set_column_comment 'people', 'source_name', 'この対象者情報の情報元のサイト名'
  set_column_comment 'people', 'source_date', 'この対象者情報の情報元における対象者情報の投稿日'
  set_column_comment 'people', 'source_url', 'この対象者情報の作成元の対象者情報への URL'
  set_column_comment 'people', 'full_name', '対象者の氏名'
  set_column_comment 'people', 'given_name', '対象者の氏名（名）'
  set_column_comment 'people', 'family_name', '対象者の氏名（姓）'
  set_column_comment 'people', 'alternate_names', '対象者の氏名（ふりがな）'
  set_column_comment 'people', 'description', '対象者の詳細な特徴／説明'
  set_column_comment 'people', 'sex', '対象者の性別'
  set_column_comment 'people', 'date_of_birth', '対象者の生年月日'
  set_column_comment 'people', 'age', '対象者の年齢'
  set_column_comment 'people', 'home_street', '対象者の住所（町名）'
  set_column_comment 'people', 'home_neighborhood', '対象者の住所（近隣の場所）'
  set_column_comment 'people', 'home_city', '対象者の住所（市区町村名）'
  set_column_comment 'people', 'home_state', '対象者の住所（都道府県名）'
  set_column_comment 'people', 'home_postal_code', '対象者の住所（郵便番号）'
  set_column_comment 'people', 'home_country', '対象者の出身国'
  set_column_comment 'people', 'photo_url', '対象者の写真の URL'
  set_column_comment 'people', 'profile_urls', '対象者のプロフィール URL'
  set_column_comment 'people', 'public_flag', '公開フラグ'
  set_column_comment 'people', 'in_city_flag', '対象者が LGDPF を運用する市区町村の住民である場合を True とするフラグ'
  set_column_comment 'people', 'shelter_name', '対象者が避難している／した避難所名'
  set_column_comment 'people', 'refuge_status', '対象者の「避難状況区分」'
  set_column_comment 'people', 'refuge_reason', '対象者が避難した理由'
  set_column_comment 'people', 'shelter_entry_date', '対象者が避難所に避難した場合の入所年月日'
  set_column_comment 'people', 'shelter_leave_date', '対象者が避難所に避難した場合の退所年月日'
  set_column_comment 'people', 'next_place', '対象者が避難所を退所した後の行き先'
  set_column_comment 'people', 'next_place_phone', '対象者が避難所を退所した後の電話番号'
  set_column_comment 'people', 'injury_flag', '対象者が災害により負傷している場合を True とするフラグ'
  set_column_comment 'people', 'injury_condition', '対象者が負傷している場合の具体的な内容'
  set_column_comment 'people', 'allergy_flag', '対象者がアレルギー保持者である場合を True とするフラグ'
  set_column_comment 'people', 'allergy_cause', '対象者がアレルギー保持者である場合の具体的な内容'
  set_column_comment 'people', 'pregnancy', '対象者が「妊婦」に該当する場合を True とするフラグ'
  set_column_comment 'people', 'baby', '対象者が該当する「乳幼児区分」'
  set_column_comment 'people', 'upper_care_level_three', '対象者が該当する「要介護度区分」'
  set_column_comment 'people', 'elderly_alone', '対象者が「６５歳以上の１人暮らしの高齢者」に該当する場合を True とするフラグ'
  set_column_comment 'people', 'elderly_couple', '対象者が「６５歳以上の高齢者のみ世帯」に該当する場合を True とするフラグ'
  set_column_comment 'people', 'bedridden_elderly', '対象者が「寝たきり高齢者」に該当する場合を True とするフラグ'
  set_column_comment 'people', 'elderly_dementia', '対象者が「認知症高齢者」に該当する場合を True とするフラグ'
  set_column_comment 'people', 'rehabilitation_certificate', '対象者が該当する「療育手帳障害区分」'
  set_column_comment 'people', 'physical_disability_certificate', '対象者が該当する「身体障害者手帳障害区分」'
  set_column_comment 'people', 'family_well', '対象者の家族について「家族全員の無事を確認した」場合を True とするフラグ'
  set_column_comment 'people', 'link_flag', 'この対象者情報を LGDPF/LGDPM 以外の安否確認システムとの間で連携することを、対象者情報の作成者が許容する場合を True とするフラグ'
  set_column_comment 'people', 'notes_disabled', 'メモ無効フラグ'
  set_column_comment 'people', 'email_flag', 'この対象者に関連する情報に変化が生じた場合にメッセージを送る事を、対象者情報の作成者が希望する場合を True とするフラグ'
  set_column_comment 'people', 'export_flag', 'この対象者に関連する情報を連携した場合を True とするフラグ'
  set_column_comment 'people', 'deleted_at', 'この対象者情報の削除日時'
  set_column_comment 'people', 'created_at', 'このレコードの作成日時'
  set_column_comment 'people', 'updated_at', 'このレコードの更新日時'

  set_table_comment 'shelters', '避難所情報'
  set_column_comment 'shelters', 'name', '避難所名'
  set_column_comment 'shelters', 'name_kana', '避難所名かな'
  set_column_comment 'shelters', 'area', '避難所の地区'
  set_column_comment 'shelters', 'address', '避難所の住所'
  set_column_comment 'shelters', 'phone', '避難所の電話番号'
  set_column_comment 'shelters', 'fax', '避難所のFAX番号'
  set_column_comment 'shelters', 'e_mail', '避難所のメールアドレス'
  set_column_comment 'shelters', 'person_responsible', '避難所の担当者名'
  set_column_comment 'shelters', 'shelter_type', '避難所種別'
  set_column_comment 'shelters', 'shelter_type_detail', '避難所種別では表現しきれない情報'
  set_column_comment 'shelters', 'shelter_sort', '避難所区分'
  set_column_comment 'shelters', 'opened_at', '開設日時'
  set_column_comment 'shelters', 'closed_at', '閉鎖日時'
  set_column_comment 'shelters', 'capacity', '最大の収容人数'
  set_column_comment 'shelters', 'status', '避難所状況'
  set_column_comment 'shelters', 'head_count', '人数（自主避難人数を含む）'
  set_column_comment 'shelters', 'head_count_voluntary', '自主避難人数'
  set_column_comment 'shelters', 'households', '世帯数（自主避難世帯数を含む）'
  set_column_comment 'shelters', 'households_voluntary', '自主避難世帯数'
  set_column_comment 'shelters', 'checked_at', '避難所状況確認日時'
  set_column_comment 'shelters', 'shelter_code', '避難所識別番号'
  set_column_comment 'shelters', 'manager_code', '管理者（職員番号）'
  set_column_comment 'shelters', 'manager_name', '管理者（名称）'
  set_column_comment 'shelters', 'manager_another_name', '管理者（別名）'
  set_column_comment 'shelters', 'reported_at', '報告日時'
  set_column_comment 'shelters', 'building_damage_info', '建物被害状況'
  set_column_comment 'shelters', 'electric_infra_damage_info', '電力被害状況'
  set_column_comment 'shelters', 'communication_infra_damage_info', '通信手段被害状況'
  set_column_comment 'shelters', 'other_damage_info', 'その他の被害'
  set_column_comment 'shelters', 'usable_flag', '使用可否'
  set_column_comment 'shelters', 'openable_flag', '開設の可否'
  set_column_comment 'shelters', 'injury_count', '負傷_計'
  set_column_comment 'shelters', 'upper_care_level_three_count', '要介護度3以上_計'
  set_column_comment 'shelters', 'elderly_alone_count', '一人暮らし高齢者（65歳以上）_計'
  set_column_comment 'shelters', 'elderly_couple_count', '高齢者世帯（夫婦共に65歳以上）_計'
  set_column_comment 'shelters', 'bedridden_elderly_count', '寝たきり高齢者_計'
  set_column_comment 'shelters', 'elderly_dementia_count', '認知症高齢者_計'
  set_column_comment 'shelters', 'rehabilitation_certificate_count', '療育手帳所持者_計'
  set_column_comment 'shelters', 'physical_disability_certificate_count', '身体障害者手帳所持者_計'
  set_column_comment 'shelters', 'note', '備考'
  set_column_comment 'shelters', 'deleted_at', '削除日時'
  set_column_comment 'shelters', 'created_by', '登録者'
  set_column_comment 'shelters', 'updated_by', '更新者'
  set_column_comment 'shelters', 'created_at', '登録日時'
  set_column_comment 'shelters', 'updated_at', '更新日時'
  set_column_comment 'shelters', 'record_mode', '記録種別'

  set_column_comment 'streets', 'id', 'ID'
  set_column_comment 'streets', 'code', '町名コード'
  set_column_comment 'streets', 'name', '町名'

  set_table_comment 'subscriptions', '購読情報'
  set_column_comment 'subscriptions', 'id', 'このレコードのプライマリ ID'
  set_column_comment 'subscriptions', 'person_record_id', 'この購読情報が紐づく対象者情報への外部キー'
  set_column_comment 'subscriptions', 'author_email', 'この購読情報が紐づく対象者の現在の電子メールアドレス'
  set_column_comment 'subscriptions', 'created_at', '登録日時'
  set_column_comment 'subscriptions', 'updated_at', '更新日時'

end
