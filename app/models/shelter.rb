# -*- coding:utf-8 -*-
class Shelter < ActiveRecord::Base
  attr_accessible :name, :name_kana, :area, :address, :phone, :fax,
   :e_mail, :person_responsible, :shelter_type, :shelter_type_detail,
   :shelter_sort, :opened_at, :closed_at, :capacity, :status, :head_count,
   :head_count_voluntary, :households, :households_voluntary, :checked_at,
   :shelter_code, :manager_code, :manager_name, :manager_another_name,
   :reported_at, :building_damage_info, :electric_infra_damage_info,
   :communication_infra_damage_info, :other_damage_info, :usable_flag,
   :openable_flag, :injury_count, :upper_care_level_three_count, :elderly_alone_count,
   :elderly_couple_count, :bedridden_elderly_count, :elderly_dementia_count,
   :rehabilitation_certificate_count, :physical_disability_certificate_count,
   :note, :deleted_at, :created_by, :updated_by

  attr_accessible :id, :created_at, :updated_at

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
