# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :person1, class: Person do |person|
    person.family_name '東京'
    person.given_name '一郎'
    person.author_name '大阪 二郎'
  end
end