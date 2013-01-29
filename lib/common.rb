# -*- coding:utf-8 -*-
class Common

  # コンスタントマスタからデータを取得する
  # === Args
  # _table_name_ :: テーブル名
  # === Return
  # 配列
  def self.get_const(table_name)
    constant_list = {}
    constant = Constant.find(:all,
      :conditions => ["kind1=? AND kind2=?", 'TD', table_name],
      :order => "kind3 ASC, _order ASC")
    constant.each do |c|
      constant_list[c.kind3] = {} unless constant_list[c.kind3]
      constant_list[c.kind3][c.value] = c.text
    end
    return constant_list
  end
end
