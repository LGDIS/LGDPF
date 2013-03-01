# -*- coding:utf-8 -*-

seeds_dir_path="#{Rails.root}/db/seeds"

# コンスタントテーブル
load("#{seeds_dir_path}/constants.rb")

# 国別コード
load("#{seeds_dir_path}/country_codes.rb")

# 避難所
load("#{seeds_dir_path}/shelters.rb")



