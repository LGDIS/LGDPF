# -*- coding:utf-8 -*-
require "csv"

Shelter.delete_all

reader = CSV.open(File.join(Rails.root,"lib", "batches", "work_shelter.csv"), "r", :encoding => "utf8")
header = reader.take(1)[0]
reader.each do |row|
  Shelter.create(
    :name => row[0],
    :area => row[1],
    :address => row[2],
    :shelter_type => row[3],
    :shelter_sort => row[4],
    :shelter_code => row[5]
  )
end
