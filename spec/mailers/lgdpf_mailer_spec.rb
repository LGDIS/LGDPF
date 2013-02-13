# -*- coding:utf-8 -*-
require 'spec_helper'

describe LgdpfMailer do
  before do
    @settings = YAML.load_file("#{Rails.root}/config/settings.yml")
    @person = FactoryGirl.create(:person, :author_email => "person@test.com", :email_flag => true)
    @note   = FactoryGirl.create(:note, :person_record_id => @person.id,
      :author_email => "note@test.com", :email_flag => true)
  end
  describe '#send_new_information' do
    context 'Personの登録の場合' do
      it '新着情報の受け取りを開始したことを通知するメールが送信されること' do
        mail = LgdpfMailer.send_new_information(@person, nil)
        mail.deliver
        mail.subject.should == "[パーソンファインダー]" + @person.full_name + "さんについての新着情報を受け取るように設定しました"
        mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
        mail.to[0].should == @person.author_email
        ActionMailer::Base.deliveries.size.should == 1
      end
    end

    context 'Noteの登録の場合' do
      it '新着情報の受け取りを開始したことを通知するメールが送信されること' do
        mail = LgdpfMailer.send_new_information(@person, @note)
        mail.deliver
        mail.subject.should == "[パーソンファインダー]" + @person.full_name + "さんについての新着情報を受け取るように設定しました"
        mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
        mail.to[0].should == @note.author_email
        ActionMailer::Base.deliveries.size.should == 1
      end
    end
  end

  describe '#send_add_note' do
    before do
      @new_note = FactoryGirl.create(:note)
    end
    context 'Personに送信する場合' do
      it '新着情報が送信されること' do
        mail = LgdpfMailer.send_add_note([@person, @new_note, @person])
        mail.deliver
        mail.subject.should == "[パーソンファインダー]" + @person.full_name + "さんについての新着情報"
        mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
        mail.to[0].should == @person.author_email
        ActionMailer::Base.deliveries.size.should == 1
      end
    end

    context 'Noteに送信する場合' do
      it '新着情報が送信されること' do
        mail = LgdpfMailer.send_add_note([@person, @new_note, @note])
        mail.deliver
        mail.subject.should == "[パーソンファインダー]" + @person.full_name + "さんについての新着情報"
        mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
        mail.to[0].should == @note.author_email
        ActionMailer::Base.deliveries.size.should == 1
      end
    end
  end

  describe '#send_delete_notice' do
    it '新着情報が送信されること' do
      mail = LgdpfMailer.send_delete_notice(@person)
      mail.deliver
      mail.subject.should == "[パーソンファインダー]" + @person.full_name + "さんの削除の通知"
      mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
      mail.to[0].should == @person.author_email
      ActionMailer::Base.deliveries.size.should == 1
    end
  end

  describe '#send_restore_notice' do
    it '新着情報が送信されること' do
      mail = LgdpfMailer.send_restore_notice(@person)
      mail.deliver
      mail.subject.should == "[パーソンファインダー]" + @person.full_name + "さんの記録の復元の通知"
      mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
      mail.to[0].should == @person.author_email
      ActionMailer::Base.deliveries.size.should == 1
    end
  end

  describe '#send_note_invalid_apply' do
    it '新着情報が送信されること' do
      mail = LgdpfMailer.send_note_invalid_apply(@person)
      mail.deliver
      mail.subject.should == "[パーソンファインダー]「" + @person.full_name + "」さんに関するメモを無効にしますか? "
      mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
      mail.to[0].should == @person.author_email
      ActionMailer::Base.deliveries.size.should == 1
    end
  end

  describe '#send_note_invalid' do
    it '新着情報が送信されること' do
      mail = LgdpfMailer.send_note_invalid(@person)
      mail.deliver
      mail.subject.should == "[パーソンファインダー]「" + @person.full_name + "」さんに関するメモが無効になりました "
      mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
      mail.to[0].should == @person.author_email
      ActionMailer::Base.deliveries.size.should == 1
    end
  end

  describe '#send_note_valid_apply' do
    it '新着情報が送信されること' do
      mail = LgdpfMailer.send_note_valid_apply(@person)
      mail.deliver
      mail.subject.should == "[パーソンファインダー]「" + @person.full_name + "」さんに関するメモを有効にしますか? "
      mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
      mail.to[0].should == @person.author_email
      ActionMailer::Base.deliveries.size.should == 1
    end
  end

  describe '#send_note_valid' do
    it '新着情報が送信されること' do
      mail = LgdpfMailer.send_note_valid(@person)
      mail.deliver
      mail.subject.should == "[パーソンファインダー]「" + @person.full_name + "」さんに関するメモが有効になりました "
      mail.from[0].should == @settings["ldgpf"]["mail"]["from"]
      mail.to[0].should == @person.author_email
      ActionMailer::Base.deliveries.size.should == 1
    end
  end


end