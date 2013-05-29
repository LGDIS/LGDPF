# -*- coding:utf-8 -*-
class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.column "person_record_id", :integer
      t.column "author_email",     :string, :limit => 500
      t.timestamps
    end

    set_table_comment(:subscriptions,                     "購読情報")
    set_column_comment(:subscriptions, :id,               "このレコードのプライマリ ID")
    set_column_comment(:subscriptions, :person_record_id, "この購読情報が紐づく対象者情報への外部キー")
    set_column_comment(:subscriptions, :author_email,     "この購読情報が紐づく対象者の現在の電子メールアドレス")
    set_column_comment(:subscriptions, :created_at,       "登録日時")
    set_column_comment(:subscriptions, :updated_at,       "更新日時")
  end
end
