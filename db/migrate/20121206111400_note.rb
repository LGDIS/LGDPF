# -*- coding:utf-8 -*-
class Note < ActiveRecord::Migration
  def up
    create_table :notes, :force => true do |t|
      t.column "note_record_id",          :string, :limit => 500
      t.column "person_record_id",        :integer
      t.column "linked_person_record_id", :string, :limit => 500
      t.column "entry_date",              :datetime
      t.column "author_name",             :string, :limit => 500
      t.column "author_email",            :string, :limit => 500
      t.column "author_phone",            :string, :limit => 500
      t.column "source_date",             :datetime
      t.column "author_made_contact",     :boolean, :default => false
      t.column "status",                  :integer
      t.column "email_of_found_person",   :string, :limit => 500
      t.column "phone_of_found_person",   :string, :limit => 500
      t.column "last_known_location",     :string, :limit => 500
      t.column "text",                    :text
      t.column "photo_url",               :string, :limit => 500
      t.column "spam_flag",               :boolean
      t.column "link_flag",               :boolean, :default => false
      t.column "email_flag",              :boolean, :default => false
      t.timestamps
    end
    
    change_table :notes do |t|
      t.set_column_comment :id,                      'このレコードのプライマリ ID'

      t.set_column_comment :note_record_id,          'このメモ情報の一意の ID（RFC4122 UUID）'
      t.set_column_comment :person_record_id,        'このメモ情報が紐づく対象者情報への外部キー'
      t.set_column_comment :linked_person_record_id, 'このメモ情報が紐づく重複した対象者情報への外部キー'
      t.set_column_comment :entry_date,              'このメモ情報の作成日時'
      t.set_column_comment :author_name,             'このメモ情報の作成者名'
      t.set_column_comment :author_email,            'このメモ情報の作成者の電子メールアドレス'
      t.set_column_comment :author_phone,            'このメモ情報の作成者の電話番号'
      t.set_column_comment :source_date,             'このメモ情報の情報元におけるメモ情報の投稿日'
      t.set_column_comment :author_made_contact,     'このメモ情報の作成者がこのメモ情報が紐づく対象者と連絡がとれた場合を True とするフラグ'
      t.set_column_comment :status,                  'このメモが表す状況区分'
      t.set_column_comment :email_of_found_person,   'このメモ情報が紐づく対象者の現在の電子メールアドレス'
      t.set_column_comment :phone_of_found_person,   'このメモ情報が紐づく対象者の現在の電話番号'
      t.set_column_comment :last_known_location,     'このメモ情報が紐づく対象者を最後に見かけた場所'
      t.set_column_comment :text,                    'このメモのメッセージ'
      t.set_column_comment :photo_url,               'このメモに関連する写真への URL'
      t.set_column_comment :spam_flag,               'このメモ情報がスパムである場合を True とするフラグ'
      t.set_column_comment :link_flag,               'このメモ情報を LGDPF/LGDPM 以外の安否確認システムとの間で連携することを、メモ情報の作成者が許容する場合を True とするフラグ'
      t.set_column_comment :email_flag,              'このメモに関連する情報に変化が生じた場合にメッセージを送る事を、メモ情報の作成者が希望する場合を True とするフラグ'
      
      t.set_column_comment :created_at,              'このレコードの作成日時'
      t.set_column_comment :updated_at,              'このレコードの更新日時'
    end
  end

  def down
  end
end
