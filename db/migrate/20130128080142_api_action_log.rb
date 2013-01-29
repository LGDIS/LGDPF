# -*- coding:utf-8 -*-
class ApiActionLog < ActiveRecord::Migration
  def up
    create_table :api_action_logs, :force => true do |t|
      t.column "unique_key", :string
      t.column "entry_date", :datetime
    end

    change_table :api_action_logs do |t|
      t.set_column_comment "unique_key", "ユニークキー"
      t.set_column_comment "entry_date", "作成日時"
    end

  end

  def down
  end
end
