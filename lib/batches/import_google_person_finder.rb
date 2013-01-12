# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::ImportGooglePersonFinder.execute
# ==== options
# 実行環境の指定 :: -e production
require 'net/http'
require 'net/https'
require "rexml/document"
Net::HTTP.version_1_2

class Batches::ImportGooglePersonFinder
  def self.execute
    p " #{Time.now.to_s} ===== START ===== "
    
    # テスト用API
    # https://google.org/personfinder/test-nokey/feeds/person
    # https://google.org/personfinder/test-nokey/feeds/note
    
    # Proxyを使用してGooglePersonFinderの情報を取得する
    # XML形式
    # 本番では不要？
    proxy_addr         = 'inet-gw.adniss.jp'
    proxy_port         = 80
    https              = Net::HTTP::Proxy(proxy_addr, proxy_port).new("google.org", 443)
    https.use_ssl      = true
    https.verify_mode  = OpenSSL::SSL::VERIFY_NONE
    https.verify_depth = 5
    
    ActiveRecord::Base.transaction do
      # -*-*-*-
      # Person
      # -*-*-*-
      response = https.get("/personfinder/test-nokey/feeds/person")
      # 取得したXMLをParseする
      doc = REXML::Document.new(response.body)
      doc.elements.each("feed/entry/pfif:person") do |e|
        # person_record_idが重複する場合は取り込まない
        person_record_id = e.elements["pfif:person_record_id"].try(:text)
        local_person = Person.find_by_person_record_id(person_record_id)
        next if local_person.present?
        # LGDPFに取り込む
        person = Person.new
        person = exec_insert_person(person, e)
        # === 暫定
        # ValidationErrorは処理しない
        # ===
        next if person.invalid?
        person.save!
      end
      # -*-*-*-
      # Note
      # -*-*-*-
      response = https.get("/personfinder/test-nokey/feeds/note")
      # 取得したXMLをParseする
      doc = REXML::Document.new(response.body)
      doc.elements.each("feed/entry/pfif:note") do |e|
        # note_record_idが重複する場合は取り込まない
        note_record_id = e.elements["pfif:note_record_id"].try(:text)
        local_note = Note.find_by_note_record_id(note_record_id)
        next if local_note.present?
        # LGDPFに取り込む
        note = Note.new
        note = exec_insert_note(note, e)
        # === 暫定
        # ValidationErrorは処理しない
        # ===
        next if note.invalid?
        note.save!
      end
    end
    
    p " #{Time.now.to_s} =====  END  ===== "
  end
  
  def self.exec_insert_person(person, e)
    person.person_record_id  = e.elements["pfif:person_record_id"].try(:text)
    entry_date               = e.elements["pfif:entry_date"].try(:text)
    person.entry_date        = entry_date.to_time if entry_date.present?
    expiry_date              = e.elements["pfif:expiry_date"].try(:text)
    person.expiry_date       = expiry_date.to_time if expiry_date.present?
    person.author_name       = e.elements["pfif:author_name"].try(:text)
    person.author_email      = e.elements["pfif:author_email"].try(:text)
    person.author_phone      = e.elements["pfif:author_phone"].try(:text)
    person.source_name       = e.elements["pfif:source_name"].try(:text)
    source_date              = e.elements["pfif:source_date"].try(:text)
    person.source_date       = source_date.to_time if source_date.present?
    person.source_url        = e.elements["pfif:source_url"].try(:text)
    person.full_name         = e.elements["pfif:full_name"].try(:text)
    person.given_name        = e.elements["pfif:given_name"].try(:text)
    person.family_name       = e.elements["pfif:family_name"].try(:text)
    person.alternate_names   = e.elements["pfif:alternate_names"].try(:text)
    person.description       = e.elements["pfif:description"].try(:text)
    sex                      = e.elements["pfif:sex"].try(:text)
    case sex
    when "male"
      person.sex = 2
    when "female"
      person.sex = 1
    when "other"
      person.sex = 3
    else
      person.sex = nil
    end
    date_of_birth            = e.elements["pfif:date_of_birth"].try(:text)
    person.date_of_birth     = date_of_birth.to_date if date_of_birth.present?
    person.age               = e.elements["pfif:age"].try(:text)
    person.home_street       = e.elements["pfif:home_street"].try(:text)
    person.home_neighborhood = e.elements["pfif:home_neighborhood"].try(:text)
    person.home_city         = e.elements["pfif:home_city"].try(:text)
    person.home_state        = e.elements["pfif:home_state"].try(:text)
    person.home_postal_code  = e.elements["pfif:home_postal_code"].try(:text)
    person.photo_url         = e.elements["pfif:photo_url"].try(:text)
    return person
  end
  
  def self.exec_insert_note(note, e)
    note.note_record_id         = e.elements["pfif:note_record_id"].try(:text)
    person_record               = Person.find_by_person_record_id(e.elements["pfif:person_record_id"].try(:text))
    note.person_record_id       = person_record.id if person_record.present?
    linked_person_record        = Person.find_by_person_record_id(e.elements["pfif:linked_person_record_id"].try(:text))
    note.linked_person_record_id       = linked_person_record.id if linked_person_record.present?
    entry_date                  = e.elements["pfif:entry_date"].try(:text)
    note.entry_date             = entry_date.to_time if entry_date.present?
    note.author_name            = e.elements["pfif:author_name"].try(:text)
    note.author_email           = e.elements["pfif:author_email"].try(:text)
    note.author_phone           = e.elements["pfif:author_phone"].try(:text)
    source_date                 = e.elements["pfif:source_date"].try(:text)
    note.source_date            = source_date.to_time if source_date.present?
    case e.elements["pfif:author_made_contact"].try(:text)
    when "true"
      author_made_contact = true
    when "false"
      author_made_contact = false
    else
      author_made_contact = nil
    end
    note.author_made_contact    = author_made_contact
    case e.elements["pfif:status"].try(:text)
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
    note.status                 = status
    note.email_of_found_person  = e.elements["pfif:email_of_found_person"].try(:text)
    note.phone_of_found_person  = e.elements["pfif:phone_of_found_person"].try(:text)
    note.last_known_location    = e.elements["pfif:last_known_location"].try(:text)
    note.text                   = e.elements["pfif:text"].try(:text)
    note.photo_url              = e.elements["pfif:photo_url"].try(:text)
    return note
  end
  
end
