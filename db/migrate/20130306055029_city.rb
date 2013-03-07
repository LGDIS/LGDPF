# -*- coding:utf-8 -*-
class City < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.integer :id
      t.string  :code
      t.string  :name
      t.timestamps
    end

    set_column_comment(:cities, :id,   "ID")
    set_column_comment(:cities, :code, "市区町村コード")
    set_column_comment(:cities, :name, "市区町村名")
  end
end
