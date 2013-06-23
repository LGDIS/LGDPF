# -*- coding:utf-8 -*-
class Street < ActiveRecord::Base
  attr_accessible :code, :name

  # 町名ハッシュ取得処理
  # ==== Args
  # _term_ :: ユーザ入力値
  # ==== Return
  # 町名ハッシュオブジェクト {:code=>:name, :code=>:name}
  # ==== Raise
  def self.hash_for_table(term)
    streets_list = {}
    streets = Street.where("name LIKE '%#{term}%'").order(:code)
    streets.each do |street|
      streets_list[street.code] = {} unless streets_list[street.code]
      streets_list[street.code] = street.name
    end
    return streets_list
  end
end