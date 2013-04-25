# -*- coding:utf-8 -*-
require 'spec_helper'
require 'rexml/document'

describe Person do
  describe 'set_attributes' do
    before do
      @person = FactoryGirl.build(:person)
    end
    context '正常入力の場合' do
      it 'saveが成功すること' do
        @person.save.should == true
      end
      it 'source_dateが現在時刻' do
        time_now = Time.zone.now
        Time.stub!(:now).and_return(time_now)
        @person.save
        @person.source_date.to_s.should == time_now.to_s
        Time.rspec_reset
      end
      it 'entry_dateが現在時刻' do
        time_now = Time.zone.now
        Time.stub!(:now).and_return(time_now)
        @person.save
        @person.entry_date.to_s.should == time_now.to_s
        Time.rspec_reset
      end
      it 'full_nameがfamily_nameとgiven_nameを半角スペースで結合していること' do
        @person.save
        @person.full_name.should == @person.family_name + " " + @person.given_name
      end
      context 'injury_conditionが未入力の場合' do
        it 'injury_flagに負傷無しが登録されること' do
          @person.injury_condition = ""
          @person.save
          @person.injury_flag == Person::INJURY_FLAG_OFF
        end
      end
      context 'injury_conditionが入力の場合' do
        it 'injury_flagに負傷が登録されること' do
          @person.injury_condition = "怪我"
          @person.save
          @person.injury_flag == Person::INJURY_FLAG_ON
        end
      end
      context 'allergy_causeが未入力の場合' do
        it 'allergy_flagにアレルギー無しが登録されること' do
          @person.allergy_cause = ""
          @person.save
          @person.allergy_flag == Person::ALLERGY_FLAG_OFF
        end
      end
      context 'allergy_causeが入力の場合' do
        it 'allergy_flagにアレルギー有りが登録されること' do
          @person.allergy_cause = "アレルギー"
          @person.save
          @person.allergy_flag == Person::ALLERGY_FLAG_ON
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
        it 'in_city_flagに市内が登録されること' do
          @person.home_state = "宮城県"
          @person.home_city = "石巻市"
          @person.save
          @person.in_city_flag == Person::IN_CITY_FLAG_INSIDE
        end
      end
      context 'home_stateが「宮城県」以外 && home_cityが「石巻市」' do
        it 'in_city_flagに市外が登録されること' do
          @person.home_state = "東京都"
          @person.home_city = "石巻市"
          @person.save
          @person.in_city_flag == Person::IN_CITY_FLAG_OUTSIDE
        end
      end
      context 'home_stateが「宮城県」 && home_cityが「石巻市」以外' do
        it 'in_city_flagに市外が登録されること' do
          @person.home_state = "東京都"
          @person.home_city = "仙台市"
          @person.save
          @person.in_city_flag == Person::IN_CITY_FLAG_OUTSIDE
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

    describe "validation" do
      let(:model) { FactoryGirl.create(:person) }

      it_should_behave_like :max_length, :person_record_id
      it_should_behave_like :max_length, :full_name
      it_should_behave_like :max_length, :family_name
      it_should_behave_like :max_length, :given_name
      it_should_behave_like :max_length, :alternate_names
      it_should_behave_like :max_length, :sex
      it_should_behave_like :max_length, :home_postal_code
      it_should_behave_like :max_length, :in_city_flag
      it_should_behave_like :max_length, :home_state
      it_should_behave_like :max_length, :home_city
      it_should_behave_like :max_length, :home_street
      it_should_behave_like :max_length, :shelter_name
      it_should_behave_like :max_length, :refuge_status
      it_should_behave_like :max_length, :next_place
      it_should_behave_like :max_length, :next_place_phone
      it_should_behave_like :max_length, :injury_flag
      it_should_behave_like :max_length, :allergy_flag
      it_should_behave_like :max_length, :pregnancy
      it_should_behave_like :max_length, :baby
      it_should_behave_like :max_length, :upper_care_level_three
      it_should_behave_like :max_length, :elderly_alone
      it_should_behave_like :max_length, :elderly_couple
      it_should_behave_like :max_length, :bedridden_elderly
      it_should_behave_like :max_length, :elderly_dementia
      it_should_behave_like :max_length, :rehabilitation_certificate
      it_should_behave_like :max_length, :physical_disability_certificate
      it_should_behave_like :max_length, :source_name
      it_should_behave_like :max_length, :source_url

      it_should_behave_like :presence, :family_name
      it_should_behave_like :presence, :given_name
      it_should_behave_like :presence, :author_name

      it_should_behave_like :date, :date_of_birth
      it_should_behave_like :date, :shelter_entry_date
      it_should_behave_like :date, :shelter_leave_date

      it_should_behave_like :datetime, :source_date
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

  describe 'exec_insert_person' do
    before do
      pfif = File.open("spec/pfif_sample.xml", "r").read
      doc = REXML::Document.new(pfif)
      @elements = doc.elements["pfif:pfif/pfif:person"]
      @person = Person.new
    end
    it 'マッピングが合っていること' do
      Person.exec_insert_person(@person, @elements)

      @person.person_record_id.should == @elements.elements["pfif:person_record_id"].text
      @person.entry_date.should       == @elements.elements["pfif:entry_date"].text.to_time
      @person.expiry_date.should      == @elements.elements["pfif:expiry_date"].text.to_time
      @person.author_name.should      == @elements.elements["pfif:author_name"].text
      @person.author_email.should     == @elements.elements["pfif:author_email"].text
      @person.author_phone.should     == @elements.elements["pfif:author_phone"].text
      @person.source_name.should      == @elements.elements["pfif:source_name"].text
      @person.source_date.should      == @elements.elements["pfif:source_date"].text
      @person.source_url.should       == @elements.elements["pfif:source_url"].text
      @person.full_name.should        == @elements.elements["pfif:full_name"].text
      @person.given_name.should       == @elements.elements["pfif:given_name"].text
      @person.family_name.should      == @elements.elements["pfif:family_name"].text
      @person.alternate_names.should  == @elements.elements["pfif:alternate_names"].text
      @person.description.should      == @elements.elements["pfif:description"].text
      sex                      = @elements.elements["pfif:sex"].try(:text)
      case sex
      when "male"
        sex = "1"
      when "female"
        sex = "2"
      when "other"
        sex = "3"
      else
        sex = nil
      end
      @person.sex.should == sex
      @person.date_of_birth.should     == @elements.elements["pfif:date_of_birth"].text.to_date
      @person.age.should               == @elements.elements["pfif:age"].text
      @person.home_street.should       == @elements.elements["pfif:home_street"].text
      @person.home_neighborhood.should == @elements.elements["pfif:home_neighborhood"].text
      @person.home_city.should         == @elements.elements["pfif:home_city"].text
      @person.home_state.should        == @elements.elements["pfif:home_state"].text
      @person.home_postal_code.should  == @elements.elements["pfif:home_postal_code"].text
      @person.home_country.should      == @elements.elements["pfif:home_country"].text
      # CarrierWaveの記述に合わせてremote_XXX_urlの書式にしてある
      @person.remote_photo_url_url.should == @elements.elements["pfif:photo_url"].text
      @person.profile_urls.should      == @elements.elements["pfif:profile_urls"].text
    end
  end

  describe 'find_for_export_gpf' do
    before do
      @person_open  = FactoryGirl.create(:person, :public_flag => Person::PUBLIC_FLAG_ON)
      @person_local = FactoryGirl.create(:person, :public_flag => Person::PUBLIC_FLAG_OFF)
    end
    it '公開対象のレコードを抽出すること' do
      Person.all.size.should == 2
      record = Person.find_for_export_gpf
      record.size.should == 1
      record[0].public_flag.should == Person::PUBLIC_FLAG_ON
    end
  end


end
