# -*- coding:utf-8 -*-
FactoryGirl.define do
  factory :note do
    person_record_id {FactoryGirl.create(:person).id}
    text 'メッセージ'
    author_name '投稿者'
  end

end
