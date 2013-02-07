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

  describe 'Validation' do
    before do
      @person = FactoryGirl.build(:person1)
    end
    describe 'family_name' do
      context 'nilの場合' do
        it '失敗すること' do
          @person.family_name = nil
          @person.save.should == false
        end
      end
      context '空文字の場合' do
        it '失敗すること' do
          @person.family_name = ""
          @person.save.should == false
        end
      end
    end
    describe 'givan_name' do
      context 'nilの場合' do
        it '失敗すること' do
          @person.given_name = nil
          @person.save.should == false
        end
      end
      context '空文字の場合' do
        it '失敗すること' do
          @person.given_name = ""
          @person.save.should == false
        end
      end
    end
    describe 'author_name' do
      context 'nilの場合' do
        it '失敗すること' do
          @person.author_name = nil
          @person.save.should == false
        end
      end
      context '空文字の場合' do
        it '失敗すること' do
          @person.author_name = ""
          @person.save.should == false
        end
      end
    end
    describe 'age' do
      context '10の場合' do
        it '成功すること' do
          @person.age = "10"
          @person.save.should == true
        end
        it '10が保存されること' do
          @person.age = "10"
          @person.save
          @person.age.should == "10"
        end
      end
      context '10-20の場合' do
        it '成功すること' do
          @person.age = "10-20"
          @person.save.should == true
        end
        it '10-20が保存されること' do
          @person.age = "10-20"
          @person.save
          @person.age.should == "10-20"
        end
      end
      context '１０の場合' do
        it '失敗すること' do
          @person.age = "１０"
          @person.save.should == false
        end
      end
      context '１０－２０の場合' do
        it '失敗すること' do
          @person.age = "１０－２０"
          @person.save.should == false
        end
      end
      context '10-20-30の場合' do
        it '失敗すること' do
          @person.age = "10-20-30"
          @person.save.should == false
        end
      end

    end
    describe 'date_of_birth' do
      context 'nilの場合'do
        it '成功すること' do
          @person.date_of_birth = nil
          @person.save.should == true
        end
      end
      context '空文字の場合'do
        it '成功すること' do
          @person.date_of_birth = ""
          @person.save.should == true
        end
      end
      context '2013-1-1の場合' do
        it '成功すること' do
          @person.date_of_birth = "2013-1-1"
          @person.save.should == true
        end
        it '2013-01-01が保存されること' do
          @person.date_of_birth = "2013-1-1"
          @person.save
          @person.date_of_birth == "2013-01-01"
        end
      end
      context '2013-01-01の場合' do
        it '成功すること' do
          @person.date_of_birth = "2013-01-01"
          @person.save.should == true
        end
        it '2013-01-01が保存されること' do
          @person.date_of_birth = "2013-01-01"
          @person.save
          @person.date_of_birth == "2013-01-01"
        end
      end
      context '2013-13-01の場合' do
        it '失敗すること' do
          @person.date_of_birth = "2013-13-01"
          @person.save.should == false
        end
      end
      context '2013-1-40の場合' do
        it '失敗すること' do
          @person.date_of_birth = "2013-1-40"
          @person.save.should == false
        end
      end
      context '2013/1/1の場合' do
        it '失敗すること' do
          @person.date_of_birth = '2013/1/1'
          @person.save.should == false
        end
      end

    end
    describe 'profile_urls' do
      context 'nilの場合' do
        it '成功すること' do
          @person.profile_urls = nil
          @person.save.should == true
        end
      end
      context '空文字の場合' do
        it '成功すること' do
          @person.profile_urls = ""
          @person.save.should == true
        end
      end
      context 'http://aaa.comの場合' do
        it '成功すること' do
          @person.profile_urls = "http://aaa.com"
          @person.save.should == true
        end
      end
      context 'https://aaa.comの場合' do
        it '成功すること' do
          @person.profile_urls = "https://aaa.com"
          @person.save.should == true
        end
      end
      context 'http://aaa.com\nhttp://bbb.comの場合' do
        it '成功すること' do
          @person.profile_urls = "http://aaa.com\nhttp://bbb.com"
          @person.save.should == true
        end
      end
      context 'http://aaa.com\nhttp://bbb.com\nhttp://ccc.comの場合' do
        it '成功すること' do
          @person.profile_urls = "http://aaa.com\nhttp://bbb.com\nhttp://ccc.com"
          @person.save.should == true
        end
      end
      context 'ftp://ddd.comの場合' do
        it '失敗すること' do
          @person.profile_urls = "ftp://ddd.com"
          @person.save.should == false
        end
      end
      context 'hogehogeの場合' do
        it '失敗すること' do
          @person.profile_urls = "hogehoge"
          @person.save.should == false
        end
      end

    end

  end

  describe 'find_for_seek' do
    before do
      @param = {:name => nil}
      @person1 = FactoryGirl.create(:person1)
      @person2 = FactoryGirl.create(:person1, :family_name => "神奈川")
      @person3 = FactoryGirl.create(:person1, :given_name => "二郎")
      @person4 = FactoryGirl.create(:person1, :alternate_names => "とうきょう")
      @person5 = FactoryGirl.create(:person1, :alternate_names => "いちろう")
    end
    context 'パラメータ不正の場合' do
      it 'return nil' do
        Person.find_for_seek(@param).should be_nil
        @param[:name].should be_blank
      end
    end
    context '1件も検索結果がない場合' do
      it 'return nil' do
        @param = {:name => "アメリカ"}
        Person.find_for_seek(@param).should be_blank
      end
    end
    context '検索結果がある場合' do
      it 'return Personレコード' do
        @param = {:name => "東京"}
        people = Person.find_for_seek(@param)
        result = Person.find(:all,
          :conditions => ["(full_name LIKE :name) OR (alternate_names LIKE :name)",
            :name => "東京"])
        people.should == result
      end
    end
  end
end