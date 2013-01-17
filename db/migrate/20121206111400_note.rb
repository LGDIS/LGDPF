# -*- coding:utf-8 -*-
class Note < ActiveRecord::Migration
  def up
    create_table :notes, :force => true do |t|
      t.column "note_record_id", :string
      t.column "person_record_id", :integer
      t.column "linked_person_record_id", :string
      t.column "entry_date", :datetime
      t.column "author_name", :string
      t.column "author_email", :string
      t.column "author_phone", :string
      t.column "source_date", :datetime
      t.column "author_made_contact", :boolean
      t.column "status", :integer
      t.column "email_of_found_person", :string
      t.column "phone_of_found_person", :string
      t.column "last_known_location", :string
      t.column "text", :text
      t.column "photo_url", :string
      t.column "spam_flag", :boolean
      t.column "link_flag", :boolean, :default => false
      t.column "email_flag", :boolean, :default => false
      t.timestamps
    end
    
    change_table :notes do |t|
      t.set_column_comment :note_record_id, 'GooglePersonFinderのnote_id'
      t.set_column_comment :person_record_id, '避難者情報との外部キー'
      t.set_column_comment :linked_person_record_id, '重複キー'
      t.set_column_comment :entry_date, '登録日'
      t.set_column_comment :author_name, '投稿者'
      t.set_column_comment :author_email, '投稿者のメールアドレス'
      t.set_column_comment :author_phone, '投稿者の電話番号'
      t.set_column_comment :source_date, '作成日時'
      t.set_column_comment :author_made_contact, '連絡の有無'
      t.set_column_comment :status, '状況'
      t.set_column_comment :email_of_found_person, '避難者のメールアドレス'
      t.set_column_comment :phone_of_found_person, '避難者の電話番号'
      t.set_column_comment :last_known_location, '最後に見かけた場所'
      t.set_column_comment :text, 'メッセージ'
      t.set_column_comment :photo_url, '写真のURL'
      t.set_column_comment :spam_flag, 'スパムフラグ'
      t.set_column_comment :link_flag, '連携フラグ'
      t.set_column_comment :email_flag, "新着メッセージ受取フラグ"
    end
  end

  def down
  end
end
