# -*- coding:utf-8 -*-
require 'spec_helper'

describe 'Person' do
  describe 'set_attributes' do
    before do
     @person = FactoryGirl.build(:person1)
    end
    context '正常入力の場合' do
      it 'saveが成功すること' do
        @person.save.should == true
      end
      it 'source_dateが現在時刻' do
        @person.save
        @person.source_date.to_s.should == Time.now.to_s
      end
      it 'entry_dateが現在時刻' do
        @person.save
        @person.entry_date.to_s.should == Time.now.to_s
      end
      it 'full_nameがfamily_nameとgiven_nameを半角スペースで結合していること' do
        @person.save
        @person.full_name.should == @person.family_name + " " + @person.given_name
      end
    end

  end
end