# -*- coding:utf-8 -*-
require 'spec_helper'

describe 'Person' do
  describe 'set_attributes' do
    before do
      @person = FactoryGirl.build(:person)
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
      context 'injury_conditionが未入力の場合' do
        it 'injury_flagに0が登録されること' do
          @person.injury_condition = ""
          @person.save
          @person.injury_flag == 0
        end
      end
      context 'injury_conditionが入力の場合' do
        it 'injury_flagに0が登録されること' do
          @person.injury_condition = "怪我"
          @person.save
          @person.injury_flag == 1
        end
      end
      context 'allergy_causeが未入力の場合' do
        it 'allergy_flagに0が登録されること' do
          @person.allergy_cause = ""
          @person.save
          @person.allergy_flag == 0
        end
      end
      context 'allergy_causeが入力の場合' do
        it 'allergy_flagに0が登録されること' do
          @person.allergy_cause = "アレルギー"
          @person.save
          @person.allergy_flag == 1
        end
      end
      context 'home_stateが未入力 && home_cityが未入力' do
        it 'in_city_flagにnilが登録されること' do
          @person.home_state = ""
          @person.home_city = ""
          @person.save
          @person.in_city_flag == nil
        end
      end
      context 'home_stateが入力 && home_cityが未入力' do
        it 'in_city_flagにnilが登録されること' do
          @person.home_state = "東京都"
          @person.home_city = ""
          @person.save
          @person.in_city_flag == nil
        end
      end
      context 'home_stateが未入力 && home_cityが入力' do
        it 'in_city_flagにnilが登録されること' do
          @person.home_state = ""
          @person.home_city = "新宿区"
          @person.save
          @person.in_city_flag == nil
        end
      end
      context 'home_stateが「宮城県」 && home_cityが「石巻市」' do
        it 'in_city_flagに1が登録されること' do
          @person.home_state = "宮城県"
          @person.home_city = "石巻市"
          @person.save
          @person.in_city_flag == 1
        end
      end
      context 'home_stateが「宮城県」以外 && home_cityが「石巻市」' do
        it 'in_city_flagに0が登録されること' do
          @person.home_state = "東京都"
          @person.home_city = "石巻市"
          @person.save
          @person.in_city_flag == 0
        end
      end
      context 'home_stateが「宮城県」 && home_cityが「石巻市」以外' do
        it 'in_city_flagに0が登録されること' do
          @person.home_state = "東京都"
          @person.home_city = "仙台市"
          @person.save
          @person.in_city_flag == 0
        end
      end

    end
  end

  describe 'Validation' do
    before do
      @person = FactoryGirl.build(:person)
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
      context '2013/1/1の場合' do
        it '成功すること' do
          @person.date_of_birth = '2013/1/1'
          @person.save.should == true
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

    describe 'メールアドレス' do
      context '空の場合' do
        it '成功すること' do
          @person.author_email = ""
          @person.save.should == true
        end
      end
      context 'test-01@test.jpの場合' do
        it '成功すること' do
          @person.author_email = "test-01@test.jp"
          @person.save.should == true
        end
      end
      context 'aaa@bbbの場合' do
        it '成功すること' do
          @person.author_email = "aaa@bbb"
          @person.save.should == true
        end
      end
      context 'aa@bb@ccの場合' do
        it '失敗すること' do
          @person.author_email = "aa@bb@cc"
          @person.save.should == false
        end
      end
    end

    describe '電話番号' do
      context '空の場合' do
        it '成功すること' do
          @person.author_phone = ""
          @person.save.should == true
        end
      end
      context '000-1111-2222の場合' do
        it '成功すること' do
          @person.author_phone = "000-1111-2222"
          @person.save.should == true
        end
      end
      context '123456789の場合' do
        it '成功すること' do
          @person.author_phone = "123456789"
          @person.save.should == true
        end
      end
      context 'a-111-222の場合' do
        it '失敗すること' do
          @person.author_phone = "a-111-222"
          @person.save.should == false
        end
      end

    end

  end

  describe 'find_for_seek' do
    before do
      @param = {:name => nil}
      @person1 = FactoryGirl.create(:person)
      @person2 = FactoryGirl.create(:person, :family_name => "神奈川")
      @person3 = FactoryGirl.create(:person, :given_name => "二郎")
      @person4 = FactoryGirl.create(:person, :alternate_names => "とうきょう")
      @person5 = FactoryGirl.create(:person, :alternate_names => "いちろう")
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
            :name => "%東京%"])
        people.should == result
      end
    end
  end

  describe 'find_for_provide' do
    before do
      @param = {:family_name => nil, :given_name => nil}
      @person1 = FactoryGirl.create(:person)
      @person2 = FactoryGirl.create(:person, :family_name => "神奈川")
      @person3 = FactoryGirl.create(:person, :given_name => "二郎")
      @person4 = FactoryGirl.create(:person, :alternate_names => "とうきょう")
      @person5 = FactoryGirl.create(:person, :alternate_names => "いちろう")
    end
    context 'パラメータ不正の場合' do
      it 'return nil' do
        Person.find_for_provide(@param).should be_nil
        @param[:family_name].should be_blank
        @param[:given_name].should be_blank
      end
    end
    context '1件も検索結果がない場合' do
      it 'return nil' do
        @param = {:name => "アメリカ"}
        Person.find_for_provide(@param).should be_blank
      end
    end
    context '検索結果がある場合' do
      it 'return Personレコード' do
        @param = {:family_name => "東京", :given_name => "一郎"}
        people = Person.find_for_provide(@param)
        result = Person.find(:all,
          :conditions => ["((family_name LIKE :family_name) AND (given_name LIKE :given_name)) OR
        ((alternate_names LIKE :family_name) AND (alternate_names LIKE :given_name))",
            :family_name => "%東京%", :given_name => "%一郎%"])
      end
    end
  end

  describe 'check_dup' do
    before do
      @person     = FactoryGirl.create(:person)
      @person_dup = FactoryGirl.create(:person)
    end
    context 'パラメータが不正の場合' do
      it 'return false' do
        result = Person.check_dup("")
        result.should == false
      end
    end
    context '重複レコードを持っていない場合' do
      before do
        @note = FactoryGirl.create(:note, :person_record_id => @person.id)
      end
      it 'return false' do
        result = Person.check_dup(@person.id)
        result.should == false
      end
    end
    context '重複レコードを持っている場合' do
      before do
        FactoryGirl.create(:note,
          :person_record_id => @person.id,
          :linked_person_record_id => @person_dup.id)
      end
      it 'return true' do
        result = Person.check_dup(@person.id)
        result.should == true
      end
    end
  end

  describe 'duplication' do
    before do
      @person     = FactoryGirl.create(:person)
      @person_dup = FactoryGirl.create(:person)
      @note_dup = FactoryGirl.create(:note, :person_record_id => @person.id,
        :linked_person_record_id => @person_dup.id)
    end
    context '重複しているpersonが1件もない場合' do
      it 'return []' do
        result = Person.duplication(@person_dup.id)
        result.should == []
      end
    end

    context '重複するpersonがある場合' do
      it '重複するpersonを抽出すること' do
        result = Person.duplication(@person.id)
        result.should == [@person_dup]
      end
    end

  end

  describe 'subscribe_email_address' do
    before do
      @person = FactoryGirl.create(:person)
      @person_no_note = FactoryGirl.create(:person)
      @note = FactoryGirl.create(:note,
        :person_record_id => @person.id, :email_flag => true, :author_email => "aaa@aaa.com")
      @new_note = FactoryGirl.create(:note,:person_record_id => @person.id)
    end
    context 'personが送信可能なnoteを持っている場合' do
      it '[person, new_note, 送信先のレコード]の形式の配列を返すこと' do
        result = Person.subscribe_email_address(@person, @new_note)
        send_record = Note.find(@note.id, :select => "author_email, id" )
        result.should == [ [@person, @new_note, send_record ] ]
      end
    end
    context 'personが送信可能なnoteを持っていない場合' do
      it '[]を返すこと' do
        result = Person.subscribe_email_address(@person_no_note, @new_note)
        send_record = Note.find(@note.id, :select => "author_email, id" )
        result.should == []
      end
    end
  end


end