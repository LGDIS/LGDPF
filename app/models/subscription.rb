# -*- coding:utf-8 -*-
class Subscription < ActiveRecord::Base
  attr_accessible :person_record_id, :author_email

  validates :author_email, :allow_blank => true, :format => { :with => /^[^@]+@[^@]+$/ } # メールアドレス
end
