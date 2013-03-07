# -*- coding:utf-8 -*-
class Street < ActiveRecord::Migration
  def change
    create_table :streets do |t|
      t.integer :id
      t.string  :code
      t.string  :name
      t.timestamps
    end

    set_column_comment(:streets, :id,   "ID")
    set_column_comment(:streets, :code, "町名コード")
    set_column_comment(:streets, :name, "町名")
  end
end
