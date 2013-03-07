# -*- coding:utf-8 -*-
class City < ActiveRecord::Base
  attr_accessible :code, :name

  # 市区町村ハッシュ取得処理
  # ==== Args
  # _term_ :: ユーザ入力値
  # ==== Return
  # 市区町村ハッシュオブジェクト {:code=>:name, :code=>:name}
  # ==== Raise
  def self.hash_for_table(term)
    cities_list = {}
    cities = City.where("name LIKE '%#{term}%'").order(:code)
    cities.each do |city|
      cities_list[city.code] = {} unless cities_list[city.code]
      cities_list[city.code] = city.name
    end
    return cities_list
  end
end