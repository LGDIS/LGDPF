# -*- coding:utf-8 -*-
require 'spec_helper'
require 'rexml/document'


describe 'Note' do
  describe 'Validation' do
    before do
      @note = FactoryGirl.build(:note)
    end
    describe 'text' do
      context 'nilの場合' do
        it '失敗すること' do
          @note.text = nil
          @note.save.should == false
        end
      end
      context '空文字の場合' do
        it '失敗すること' do
          @note.text = ""
          @note.save.should == false
        end
      end
    end

    describe 'author_name' do
      context 'nilの場合' do
        it '失敗すること' do
          @note.author_name = nil
          @note.save.should == false
        end
      end
      context '空文字の場合' do
        it '失敗すること' do
          @note.author_name = ""
          @note.save.should == false
        end
      end
    end

    describe 'author_email' do
      context '空の場合' do
        it '成功すること' do
          @note.author_email = ""
          @note.save.should == true
        end
      end
      context 'test-01@test.jpの場合' do
        it '成功すること' do
          @note.author_email = "test-01@test.jp"
          @note.save.should == true
        end
      end
      context 'aaa@bbbの場合' do
        it '成功すること' do
          @note.author_email = "aaa@bbb"
          @note.save.should == true
        end
      end
      context 'aa@bb@ccの場合' do
        it '失敗すること' do
          @note.author_email = "aa@bb@cc"
          @note.save.should == false
        end
      end
    end

    describe 'author_phone' do
      context '空の場合' do
        it '成功すること' do
          @note.author_phone = ""
          @note.save.should == true
        end
      end
      context '000-1111-2222の場合' do
        it '成功すること' do
          @note.author_phone = "000-1111-2222"
          @note.save.should == true
        end
      end
      context '123456789の場合' do
        it '成功すること' do
          @note.author_phone = "123456789"
          @note.save.should == true
        end
      end
      context 'a-111-222の場合' do
        it '失敗すること' do
          @note.author_phone = "a-111-222"
          @note.save.should == false
        end
      end
    end

    describe 'author_made_contact' do
      context 'statusが「本人である」&& author_made_contactが「いいえ」の場合'
      it 'エラーメッセージが追加されること' do
        @note.status = 3
        @note.author_made_contact = false
        @note.save
        @note.errors.full_messages[0].strip.should == I18n.t("activerecord.attributes.note.author_made_contact")
      end
    end

    describe "validation" do
      let(:model) { FactoryGirl.create(:note) }

      it_should_behave_like :max_length, :note_record_id
      it_should_behave_like :max_length, :linked_person_record_id
      it_should_behave_like :max_length, :author_name
      it_should_behave_like :max_length, :email_of_found_person
      it_should_behave_like :max_length, :phone_of_found_person
      it_should_behave_like :max_length, :last_known_location

      it_should_behave_like :presence, :text
      it_should_behave_like :presence, :author_name

      it_should_behave_like :datetime, :entry_date
      it_should_behave_like :datetime, :source_date
      
    end


  end

  describe 'duplication' do
    it 'Personの持つ重複確認noteを抽出すること' do
      @person     = FactoryGirl.create(:person)
      @person_dup = FactoryGirl.create(:person)
      @note = FactoryGirl.create(:note,
        :person_record_id => @person.id, :linked_person_record_id => @person_dup.id)
      expect = Note.duplication(@person.id)
      got   = Note.find(:all, :conditions => ["linked_person_record_id IS NOT NULL AND person_record_id = ?", @person.id])

      expect.should == got
    end
  end

  describe 'no_duplication' do
    it 'Personの持つ重複確認note以外を抽出すること' do
      @person     = FactoryGirl.create(:person)
      @person_dup = FactoryGirl.create(:person)
      @note       = FactoryGirl.create(:note)
      @note_dup   = FactoryGirl.create(:note,
        :person_record_id => @person.id, :linked_person_record_id => @person_dup.id)
      expect = Note.no_duplication(@person.id)
      got   = Note.find(:all,
        :conditions => ["linked_person_record_id IS NULL AND person_record_id = ?", @person.id],
        :order => "entry_date ASC")

      expect.should == got
    end
  end

  describe 'check_for_author_email' do
    context 'personとそれに紐付くnoteに重複するauthor_emailがある場合' do
      it 'return true' do
        @person = FactoryGirl.create(:person, :author_email => "aaa@aaa.com")
        FactoryGirl.create(:note, :person_record_id => @person.id, :author_email => "aaa@aaa.com")
        FactoryGirl.create(:note, :person_record_id => @person.id, :author_email => "bbb@aaa.com")
        result = Note.check_for_author_email(@person)
        result.should == true        
      end
    end

    context 'personとそれに紐付くnoteに重複するauthor_emailがない場合' do
      it 'return false' do
        @person = FactoryGirl.create(:person, :author_email => "aaa@aaa.com")
        FactoryGirl.create(:note, :person_record_id => @person.id, :author_email => "bbb@aaa.com")
        FactoryGirl.create(:note, :person_record_id => @person.id, :author_email => "ccc@aaa.com")
        result = Note.check_for_author_email(@person)
        result.should == false
      end
    end

  end


  describe 'exec_insert_note' do
    before do
      pfif = File.open("spec/pfif_sample.xml", "r").read
      doc = REXML::Document.new(pfif)
      elements = doc.elements["pfif:pfif/pfif:person"]
      person = Person.new
      person = Person.exec_insert_person(person, elements)
      person.save
      @note = Note.new
      @elements = doc.elements["pfif:pfif/pfif:person/pfif:note"]
    end
    it 'マッピングが合っていること' do
      Note.exec_insert_note(@note, @elements)
      person_record = Person.find_by_person_record_id(@elements.elements["pfif:person_record_id"].text)
      linked_person_record = Person.find_by_person_record_id(@elements.elements["pfif:linked_person_record_id"].text)

      @note.note_record_id.should          == @elements.elements["pfif:note_record_id"].text
      @note.person_record_id.should        == person_record.id
      @note.linked_person_record_id.should == linked_person_record.id if linked_person_record.present?
      @note.entry_date.should              == @elements.elements["pfif:entry_date"].text.to_time
      @note.author_name.should             == @elements.elements["pfif:author_name"].text
      @note.author_email.should            == @elements.elements["pfif:author_email"].text
      @note.author_phone.should            == @elements.elements["pfif:author_phone"].text
      @note.source_date.should             == @elements.elements["pfif:source_date"].text.to_time
      case @elements.elements["pfif:author_made_contact"].text
      when "true"
        author_made_contact = true
      when "false"
        author_made_contact = false
      else
        author_made_contact = nil
      end
      @note.author_made_contact.should     == author_made_contact

      case @elements.elements["pfif:status"].text
      when "information_sought" # 情報を探している
        status = 2
      when "is_note_author" # 私が本人である
        status = 3
      when "believed_alive" # この人が生きているという情報を入手した
        status = 4
      when "believed_missing" # この人を行方不明と判断した理由がある
        status = 5
      else
        status = 1
      end
      @note.status.should          == status
      @note.email_of_found_person  == @elements.elements["pfif:email_of_found_person"].text
      @note.phone_of_found_person  == @elements.elements["pfif:phone_of_found_person"].text
      @note.last_known_location    == @elements.elements["pfif:last_known_location"].text
      @note.text                   == @elements.elements["pfif:text"].text
      @note.remote_photo_url_url   == @elements.elements["pfif:photo_url"].text

    end
  end


end