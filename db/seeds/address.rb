# -*- coding:utf-8 -*-
require "csv"

# 住所
City.delete_all
Street.delete_all

reader = CSV.open(File.join(Rails.root,"lib", "batches", "work_address.csv"), "r", :encoding => "utf8")
header = reader.take(1)[0]
work_state, work_city, work_street = nil, nil, nil
reader.each do |row|
  # 都道府県
  # if work_state != row[1]
    # work_state = row[1]
    # State.create(:code => row[0][0..1], :name => row[1])
  # end
  # 市区町村
  if work_city != row[2]
    work_city = row[2]
    City.create(:code => row[0][0..4], :name => row[2])
  end
  # 町名
  if work_street != row[3]
    work_street = row[3]
    Street.create(:code => row[0], :name => row[3])
  end
end
