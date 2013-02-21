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

    # APIキーの読み込み
    @settings = YAML.load_file("#{Rails.root}/config/settings.yml")

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
    response = nil
    start = Time.now
    # 30分でタイムアウト
    while (Time.now - start) < 30.minutes
      # 5分間レスポンスがない場合はタイムアウト
      timeout(5.minutes.to_i){
        url = "/personfinder/" + @settings["gpf"]["repository"] +
          "/feeds/person?key=" + @settings["gpf"]["api_key"] +
          "&max_results=200&skip=" + skip.to_s +
          "&min_entry_date=" + last_start_time.try(:utc).try(:strftime, "%Y-%m-%dT%H:%M:%SZ").to_s

        response = https.get(url)
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
          # LGDPFからuploadしたデータは取り込まない
          domain = person_record_id.split("/")
          next if local_person.present? || domain[0] == @settings["gpf"]["domain"]
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

    # -*-*-*-
    # Note
    # -*-*-*-
    # NoteのGoogleから最後に取り込んだレコードを取得する
    last_start_time = Note.where("note_record_id IS NOT NULL").order(:source_date).try(:last).try(:source_date)
    skip = 0

    response = nil
    start = Time.now
    # 30分でタイムアウト
    while (Time.now - start) < 30.minutes
      # 5分間レスポンスがない場合はタイムアウト
      timeout(5.minutes.to_i){
        url = "/personfinder/" + @settings["gpf"]["repository"] +
          "/feeds/note?key=" + @settings["gpf"]["api_key"] +
          "&max_results=200&skip=" + skip.to_s +
          "&min_entry_date=" + last_start_time.try(:utc).try(:strftime, "%Y-%m-%dT%H:%M:%SZ").to_s

        response = https.get(url)
      }
      # 取得したXMLをParseする
      doc = REXML::Document.new(response.body)
      if doc.elements["feed/entry/pfif:note"].present?
        p " #{Time.now.to_s} ===== Note   #{skip}件目 ====="
        skip = skip + 200
        doc.elements.each("feed/entry/pfif:note") do |e|
          # 紐付くPersonがないNoteは取り込まない
          person_record_id = e.elements["pfif:person_record_id"].try(:text)
          local_person = Person.find_by_person_record_id(person_record_id)
          # note_record_idが重複する場合は取り込まない
          note_record_id = e.elements["pfif:note_record_id"].try(:text)
          local_note = Note.find_by_note_record_id(note_record_id)
          # LGDPFからuploadしたデータは取り込まない
          domain = note_record_id.split("/")
          next if local_person.blank? || local_note.present? || domain[0] == @settings["gpf"]["domain"]
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

