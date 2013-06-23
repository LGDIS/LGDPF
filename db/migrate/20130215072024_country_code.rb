# -*- coding:utf-8 -*-
class CountryCode < ActiveRecord::Migration
  def up
    create_table :country_codes, :force => true do |t|
      t.column :name, :string
      t.column :code, :string
    end

    change_table :country_codes do |t|
      t.set_column_comment :name, "国名"
      t.set_column_comment :code, "国別コード"
    end
  end

  def down
  end
end
