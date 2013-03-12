# -*- coding:utf-8 -*-
class Shelter < ActiveRecord::Base
  attr_accessible :name, :name_kana, :area, :address, :shelter_type, :shelter_sort, :shelter_code

  # 定数
  # 開設状況
  SHELTER_SORT_MIKAISETSU = "1"  # 未開設
  SHELTER_SORT_KAISETSU   = "2"  # 開設
  SHELTER_SORT_HEISA      = "3"  # 閉鎖
  SHELTER_SORT_FUMEI      = "4"  # 不明
  SHELTER_SORT_JOSETSU    = "5"  # 常設

  # コンスタントマスタからデータを取得する
  # === Args
  # === Return
  # Shelterハッシュ
  def self.hash_for_selectbox
    shelter_list = {}
    shelters = Shelter.where(:shelter_sort => [SHELTER_SORT_KAISETSU, SHELTER_SORT_JOSETSU])
    shelters.each do |s|
      shelter_list[s.shelter_code] = s.name
    end
    return shelter_list
  end

end