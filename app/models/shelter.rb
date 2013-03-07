# -*- coding:utf-8 -*-
class Shelter < ActiveRecord::Base
  attr_accessible :name, :name_kana, :area, :address, :shelter_type, :shelter_sort, :shelter_code

  # コンスタントマスタからデータを取得する
  # === Args
  # === Return
  # Shelterハッシュ
  def self.hash_for_selectbox
    shelter_list = {}
    shelters = Shelter.all
    shelters.each do |s|
      shelter_list[s.shelter_code] = s.name
    end
    return shelter_list
  end

end