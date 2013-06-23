# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :subscription do
    person_record_id {FactoryGirl.create(:person).id}
  end
end
