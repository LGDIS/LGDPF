# -*- coding:utf-8 -*-
class Shelter < ActiveRecord::Base
  attr_accessible :name,:name_kana,:area,:address,:phone,:fax,:e_mail,:person_responsible,
    :shelter_type,:shelter_type_detail,:shelter_sort,:opened_date,:opened_hm,
    :closed_date, :closed_hm,:capacity,:status,:head_count_voluntary,
    :households_voluntary,:checked_date, :checked_hm,:manager_code,:manager_name,
    :manager_another_name,:reported_date, :reported_hm,:building_damage_info,
    :electric_infra_damage_info,:communication_infra_damage_info,
    :other_damage_info,:usable_flag,:openable_flag,:note,
    :head_count, :households,:injury_count, :upper_care_level_three_count,
    :elderly_alone_count, :elderly_couple_count, :bedridden_elderly_count,
    :elderly_dementia_count, :rehabilitation_certificate_count, :physical_disability_certificate_count,
    :created_by, :updated_by,:head_count,:households,:injury_count,
    :upper_care_level_three_count,:elderly_alone_count,:elderly_couple_count,
    :bedridden_elderly_count,:elderly_dementia_count,:rehabilitation_certificate_count,
    :physical_disability_certificate_count, :updated_by

end