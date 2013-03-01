# -*- coding:utf-8 -*-
require "csv"

CSV.foreach("#{Rails.root}/db/seeds/shelters.csv") do |row|
  Shelter.create(
    :name => row[0],
    :name_kana => row[1],
    :area => row[2],
    :address => row[3],
    :shelter_type => row[4],
    :shelter_sort => row[5]
  )
end