# -*- coding:utf-8 -*-
class Person < ActiveRecord::Migration
  def self.up
    create_table :people, :force => true do |t|
      t.column "person_record_id",                :string, :limit => 500
      t.column "entry_date",                      :datetime
      t.column "expiry_date",                     :datetime
      t.column "author_name",                     :string, :limit => 500
      t.column "author_email",                    :string, :limit => 500
      t.column "author_phone",                    :string, :limit => 500
      t.column "source_name",                     :string, :limit => 500
      t.column "source_date",                     :datetime
      t.column "source_url",                      :string, :limit => 500
      t.column "full_name",                       :string, :limit => 500
      t.column "given_name",                      :string, :limit => 500
      t.column "family_name",                     :string, :limit => 500
      t.column "alternate_names",                 :string, :limit => 500
      t.column "description",                     :text
      t.column "sex",                             :string, :limit => 1
      t.column "date_of_birth",                   :date
      t.column "age",                             :string, :limit => 500
      t.column "home_street",                     :string, :limit => 500
      t.column "home_neighborhood",               :string, :limit => 500
      t.column "home_city",                       :string, :limit => 500
      t.column "home_state",                      :string, :limit => 500
      t.column "home_postal_code",                :string, :limit => 500
      t.column "home_country",                    :string, :limit => 500
      t.column "photo_url",                       :string, :limit => 500
      t.column "profile_urls",                    :string, :limit => 500
      t.column "public_flag",                     :integer

      t.column "in_city_flag",                    :string, :limit => 1
      t.column "shelter_name",                    :string, :limit => 20
      t.column "refuge_status",                   :string, :limit => 1
      t.column "refuge_reason",                   :text
      t.column "shelter_entry_date",              :date
      t.column "shelter_leave_date",              :date
      t.column "next_place",                      :string, :limit => 100
      t.column "next_place_phone",                :string, :limit => 20
      t.column "injury_flag",                     :string, :limit => 1
      t.column "injury_condition",                :text
      t.column "allergy_flag",                    :string, :limit => 1
      t.column "allergy_cause",                   :text
      t.column "pregnancy",                       :string, :limit => 1
      t.column "baby",                            :string, :limit => 1
      t.column "upper_care_level_three",          :string, :limit => 2
      t.column "elderly_alone",                   :string, :limit => 1
      t.column "elderly_couple",                  :string, :limit => 1
      t.column "bedridden_elderly",               :string, :limit => 1
      t.column "elderly_dementia",                :string, :limit => 1
      t.column "rehabilitation_certificate",      :string, :limit => 2
      t.column "physical_disability_certificate", :string, :limit => 1
      t.column "family_well",                     :string, :limit => 1
      t.column "link_flag",                       :boolean, :default => false
      t.column "notes_disabled",                  :boolean, :default => false
      t.column "email_flag",                      :boolean, :default => false
      t.column "export_flag",                     :boolean, :default => false
      t.column "deleted_at",                      :datetime

      t.timestamps
    end

    change_table :people do |t|
      t.set_column_comment "id",                     "このレコードのプライマリ ID"
      
      t.set_column_comment "person_record_id",       "この対象者情報の一意の ID（RFC4122 UUID）"
      t.set_column_comment "entry_date",             "この対象者情報の作成日時"
      t.set_column_comment "expiry_date",            "この対象者情報の削除予定日時"
      t.set_column_comment "author_name",            "この対象者情報の作成者名"
      t.set_column_comment "author_email",           "この対象者情報の作成者の電子メールアドレス"
      t.set_column_comment "author_phone",           "この対象者情報の作成者の電話番号"
      t.set_column_comment "source_name",            "この対象者情報の情報元のサイト名"
      t.set_column_comment "source_date",            "この対象者情報の情報元における対象者情報の投稿日"
      t.set_column_comment "source_url",             "この対象者情報の作成元の対象者情報への URL"
      t.set_column_comment "full_name",              "対象者の氏名"
      t.set_column_comment "given_name",             "対象者の氏名（名）"
      t.set_column_comment "family_name",            "対象者の氏名（姓）"
      t.set_column_comment "alternate_names",        "対象者の氏名（ふりがな）"
      t.set_column_comment "description",            "対象者の詳細な特徴／説明"
      t.set_column_comment "sex",                    "対象者の性別"
      t.set_column_comment "date_of_birth",          "対象者の生年月日"
      t.set_column_comment "age",                    "対象者の年齢"
      t.set_column_comment "home_street",            "対象者の住所（町名）"
      t.set_column_comment "home_neighborhood",      "対象者の住所（近隣の場所）"
      t.set_column_comment "home_city",              "対象者の住所（市区町村名）"
      t.set_column_comment "home_state",             "対象者の住所（都道府県名）"
      t.set_column_comment "home_postal_code",       "対象者の住所（郵便番号）"
      t.set_column_comment "home_country",           "対象者の出身国"
      t.set_column_comment "photo_url",              "対象者の写真の URL"
      t.set_column_comment "profile_urls",           "対象者のプロフィール URL"
      t.set_column_comment "public_flag",            "公開フラグ"

      t.set_column_comment "in_city_flag",           "対象者が LGDPF を運用する市区町村の住民である場合を True とするフラグ"
      t.set_column_comment "shelter_name",           "対象者が避難している／した避難所名"
      t.set_column_comment "refuge_status",          "対象者の「避難状況区分」"
      t.set_column_comment "refuge_reason",          "対象者が避難した理由"
      t.set_column_comment "shelter_entry_date",     "対象者が避難所に避難した場合の入所年月日"
      t.set_column_comment "shelter_leave_date",     "対象者が避難所に避難した場合の退所年月日"
      t.set_column_comment "next_place",             "対象者が避難所を退所した後の行き先"
      t.set_column_comment "next_place_phone",       "対象者が避難所を退所した後の電話番号"
      t.set_column_comment "injury_flag",            "対象者が災害により負傷している場合を True とするフラグ"
      t.set_column_comment "injury_condition",       "対象者が負傷している場合の具体的な内容"
      t.set_column_comment "allergy_flag",           "対象者がアレルギー保持者である場合を True とするフラグ"
      t.set_column_comment "allergy_cause",          "対象者がアレルギー保持者である場合の具体的な内容"
      t.set_column_comment "pregnancy",              "対象者が「妊婦」に該当する場合を True とするフラグ"
      t.set_column_comment "baby",                   "対象者が該当する「乳幼児区分」"
      t.set_column_comment "upper_care_level_three", "対象者が該当する「要介護度区分」"
      t.set_column_comment "elderly_alone",          "対象者が「６５歳以上の１人暮らしの高齢者」に該当する場合を True とするフラグ"
      t.set_column_comment "elderly_couple",         "対象者が「６５歳以上の高齢者のみ世帯」に該当する場合を True とするフラグ"
      t.set_column_comment "bedridden_elderly",      "対象者が「寝たきり高齢者」に該当する場合を True とするフラグ"
      t.set_column_comment "elderly_dementia",       "対象者が「認知症高齢者」に該当する場合を True とするフラグ"
      t.set_column_comment "rehabilitation_certificate", "対象者が該当する「療育手帳障害区分」"
      t.set_column_comment "physical_disability_certificate", "対象者が該当する「身体障害者手帳障害区分」"
      t.set_column_comment "family_well",            "対象者の家族について「家族全員の無事を確認した」場合を True とするフラグ"
      t.set_column_comment "link_flag",              "この対象者情報を LGDPF/LGDPM 以外の安否確認システムとの間で連携することを、対象者情報の作成者が許容する場合を True とするフラグ"
      t.set_column_comment "notes_disabled",         "メモ無効フラグ"
      t.set_column_comment "email_flag",             "この対象者に関連する情報に変化が生じた場合にメッセージを送る事を、対象者情報の作成者が希望する場合を True とするフラグ"
      t.set_column_comment "export_flag",            "この対象者に関連する情報を連携した場合を True とするフラグ"
      t.set_column_comment "deleted_at",             "この対象者情報の削除日時"
      t.set_column_comment "created_at",             "このレコードの作成日時"
      t.set_column_comment "updated_at",             "このレコードの更新日時"
    end
  end
            
  def down
  end
end
