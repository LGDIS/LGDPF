# -*- coding:utf-8 -*-
require 'csv'

# 国別コード
CSV.foreach("#{Rails.root}/db/seeds/country_code.csv") do |row|
  CountryCode.create(:name => row[0], :code => row[1])
end