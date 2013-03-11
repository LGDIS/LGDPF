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

  # 定数
  # GooglePersonFinderからfeedデータを取得する時間
  REST_GET_TIME = 5.minutes.to_i
  # バッチの起動時間
  BATCH_BOOT_TIME =  30.minutes
  # GooglePersonFinderから1度に取得できるレコード数
  MAX_RESULTS = 200


  # GoogePersonFinderから未連携のデータを取込処理
  # === Args
  # === Return
  # === Raise
  def self.execute
    puts " #{Time.now.to_s} ===== START ===== "

    # GooglePersonFinderの情報を取得する
    # XML形式
    https              = Net::HTTP.new("google.org", 443)
    https.use_ssl      = true
    https.verify_mode  = OpenSSL::SSL::VERIFY_NONE
    https.verify_depth = 5
    
    # -*-*-*-
    # Person
    # -*-*-*-
    skip = 0
    response = nil
    start = Time.now
    # タイムアウト
    while (Time.now - start) < BATCH_BOOT_TIME
      # 登録されている連携データの最新日付
      last_start_time = Person.where("person_record_id IS NOT NULL").order(:source_date).try(:last).try(:source_date)
      # レスポンスがない場合はタイムアウト
      timeout(REST_GET_TIME){
        url = "/personfinder/" + SETTINGS["gpf"]["repository"] +
          "/feeds/person?key=" + SETTINGS["gpf"]["api_key"] +
          "&max_results=" + MAX_RESULTS.to_s + "&skip=" + skip.to_s +
          "&min_entry_date=" + last_start_time.try(:utc).try(:strftime, "%Y-%m-%dT%H:%M:%SZ").to_s

        response = https.get(url)
      }
      # 取得したXMLをParseする
      doc = REXML::Document.new(response.body)
      if doc.elements["feed/entry/pfif:person"].present?
        puts " #{Time.now.to_s} ===== Person #{skip}th ====="
        skip = skip + MAX_RESULTS
        doc.elements.each("feed/entry/pfif:person") do |e|
          # 石巻市以外のデータは取り込まない
          next unless (e.elements["pfif:home_state"].try(:text) =~ /^(宮城)県?$/ &&
              e.elements["pfif:home_city"].try(:text) =~ /^(石巻)市?$/)

          # person_record_idが重複する場合は取り込まない
          # 削除されているデータも確認する
          person_record_id = e.elements["pfif:person_record_id"].try(:text)
          local_person = Person.with_deleted.find_by_person_record_id(person_record_id)
          # 削除されていたPersonを復元
          if local_person.present? && local_person.deleted_at.present?
            local_person.recover
          end
          
          # LGDPFからuploadしたデータは取り込まない
          domain = person_record_id.split("/")
          next if local_person.present? || domain[0] == SETTINGS["gpf"]["domain"]

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
    skip = 0
    response = nil
    start = Time.now
    # 30分でタイムアウト
    while (Time.now - start) < BATCH_BOOT_TIME
      # 登録されている連携データの最新日付
      last_start_time = Note.where("note_record_id IS NOT NULL").order(:source_date).try(:last).try(:source_date)
      # 5分間レスポンスがない場合はタイムアウト
      timeout(REST_GET_TIME){
        url = "/personfinder/" + SETTINGS["gpf"]["repository"] +
          "/feeds/note?key=" + SETTINGS["gpf"]["api_key"] +
          "&max_results=" + MAX_RESULTS.to_s + "&skip=" + skip.to_s +
          "&min_entry_date=" + last_start_time.try(:utc).try(:strftime, "%Y-%m-%dT%H:%M:%SZ").to_s

        response = https.get(url)
      }
      # 取得したXMLをParseする
      doc = REXML::Document.new(response.body)
      if doc.elements["feed/entry/pfif:note"].present?
        puts " #{Time.now.to_s} ===== Note   #{skip}th ====="
        skip = skip + MAX_RESULTS
        doc.elements.each("feed/entry/pfif:note") do |e|
          # 紐付くPersonがないNoteは取り込まない
          # 削除されているPersonも確認する
          person_record_id = e.elements["pfif:person_record_id"].try(:text)
          local_person = Person.with_deleted.find_by_person_record_id(person_record_id)
          local_person.try(:recover)  # 削除されていたPersonを復元

          # note_record_idが重複する場合は取り込まない
          note_record_id = e.elements["pfif:note_record_id"].try(:text)
          local_note = Note.find_by_note_record_id(note_record_id)

          # LGDPFからuploadしたデータは取り込まない
          domain = note_record_id.split("/")

          next if local_person.blank? || local_note.present? || domain[0] == SETTINGS["gpf"]["domain"]
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
    puts " #{Time.now.to_s} ===== END   ===== "

  end

end

