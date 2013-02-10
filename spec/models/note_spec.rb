# -*- coding:utf-8 -*-
require 'spec_helper'

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

end