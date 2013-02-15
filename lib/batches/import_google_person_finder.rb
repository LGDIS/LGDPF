# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::ImportGooglePersonFinder.execute
# ==== options
# 実行環境の指定 :: -e production
# バッチを複数同時起動することは想定していないが、 現在の作りは1レコードずつ
# トランザクション処理をしているので、問題なく動作します。仕様変更時は注意する。
require 'net/http'
require 'net/https'
require 'rexml/document'
require 'timeout'
Net::HTTP.version_1_2

class Batches::ImportGooglePersonFinder
  def self.execute
    p " #{Time.now.to_s} ===== START ===== "
    
    # テスト用API
    # https://google.org/personfinder/test-nokey/feeds/person
    # https://google.org/personfinder/test-nokey/feeds/note
    
    # GooglePersonFinderの情報を取得する
    # XML形式
    https              = Net::HTTP.new("google.org", 443)
    https.use_ssl      = true
    https.verify_mode  = OpenSSL::SSL::VERIFY_NONE
    https.verify_depth = 5
    
    # -*-*-*-
    # Person
    # -*-*-*-
    # PersonのGoogleから最後に取り込んだレコードを取得する
    skip = 0
    last_start_time = Person.where("person_record_id IS NOT NULL").order(:source_date).try(:last).try(:source_date)
    begin
      
      # 30分でタイムアウト
      #      timeout(10.seconds.to_i) do

      response = nil
      start = Time.now
      while (Time.now - start) < 30.minutes
        timeout(5.minutes.to_i){
          response = https.get("/personfinder/test-nokey/feeds/person?max_results=200&skip=" +
              skip.to_s + "&min_entry_date=" + last_start_time.try(:utc).try(:strftime, "%Y-%m-%dT%H:%M:%SZ").to_s)
        }
        # 取得したXMLをParseする
        doc = REXML::Document.new(response.body)
        if doc.elements["feed/entry/pfif:person"].present?
          p " #{Time.now.to_s} ===== Person #{skip}件目 ====="
          skip = skip + 200
          doc.elements.each("feed/entry/pfif:person") do |e|
            # person_record_idが重複する場合は取り込まない
            person_record_id = e.elements["pfif:person_record_id"].try(:text)
            local_person = Person.find_by_person_record_id(person_record_id)
            next if local_person.present?
            # LGDPFに取り込む
            person = Person.new
            person = Person.exec_insert_person(person, e)
            # ValidationErrorは処理しない
            next if person.invalid?
            person.save!
          end
        else
          break
        end

      end
    end

    # -*-*-*-
    # Note
    # -*-*-*-
    # NoteのGoogleから最後に取り込んだレコードを取得する
    last_start_time = Note.where("note_record_id IS NOT NULL").order(:source_date).try(:last).try(:source_date)
    skip = 0

    response = nil
    start = Time.now
    while (Time.now - start) < 30.minutes
      timeout(5.minutes.to_i){
        response = https.get("/personfinder/test-nokey/feeds/note?max_results=200&skip=" +
            skip.to_s + "&min_entry_date=" + last_start_time.try(:utc).try(:strftime, "%Y-%m-%dT%H:%M:%SZ").to_s)
      }
      # 取得したXMLをParseする
      doc = REXML::Document.new(response.body)
      if doc.elements["feed/entry/pfif:note"].present?
        p " #{Time.now.to_s} ===== Note   #{skip}件目 ====="
        skip = skip + 200
        doc.elements.each("feed/entry/pfif:note") do |e|
          # note_record_idが重複する場合は取り込まない
          note_record_id = e.elements["pfif:note_record_id"].try(:text)
          local_note = Note.find_by_note_record_id(note_record_id)
          next if local_note.present?
          # LGDPFに取り込む
          note = Note.new
          note = Note.exec_insert_note(note, e)
          # ValidationErrorは処理しない
          next if note.invalid?
          note.save!
        end
      else
        break
      end

    end
    p " #{Time.now.to_s} ===== END   ===== "

  end

end

