# -*- coding:utf-8 -*-
require 'csv'

CountryCode.delete_all
# 国別コード
reader = CSV.open(File.join(Rails.root,"lib", "batches", "country_code.csv"), "r", :encoding => "utf8")
reader.each do |row|
  CountryCode.create(:name => row[0], :code => row[1])
end