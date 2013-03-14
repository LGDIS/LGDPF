# -*- coding:utf-8 -*-
class Person < ActiveRecord::Base
  attr_accessible :entry_date, :expiry_date, :author_name, :author_email,
    :author_phone, :source_name, :source_date, :source_url,
    :full_name, :given_name, :family_name, :alternate_names, :description,
    :sex, :date_of_birth, :age, :home_street, :home_neighborhood, :home_city,
    :home_state, :home_postal_code, :home_country,
    :in_city_flag, :shelter_name, :refuge_status, :refuge_reason,
    :shelter_entry_date, :shelter_leave_date, :next_place, :next_place_phone,
    :injury_flag, :injury_condition, :allergy_flag, :allergy_cause, :pregnancy,
    :baby, :upper_care_level_three, :elderly_alone, :elderly_couple,
    :bedridden_elderly, :elderly_dementia, :rehabilitation_certificate,
    :physical_disability_certificate, :photo_url, :profile_urls, :remote_photo_url_url,
    :public_flag, :link_flag, :house_number, :notes_disabled, :email_flag, :deleted_at,
    :profile_urls, :family_well, :export_flag

  has_many :notes
  # newレコードをsaveした場合の処理
  before_create :set_attributes
  # 論理削除機能の有効化
  acts_as_paranoid
  # 画像のアップロード
  mount_uploader :photo_url, PhotoUrlUploader


  # --*--*-- 定数 --*--*--
  # 市内・市外区分
  IN_CITY_FLAG_INSIDE  = 1 # 市内
  IN_CITY_FLAG_OUTSIDE = 0 # 市外
  # 負傷
  INJURY_FLAG_ON      = 1 # 有
  INJURY_FLAG_OFF      = 0 # 無
  # アレルギー
  ALLERGY_FLAG_ON     = 1 # アレルギー有
  ALLERGY_FLAG_OFF     = 0 # アレルギー無
  # 公開フラグ
  PUBLIC_FLAG_ON      = 1 # 公開
  PUBLIC_FLAG_OFF      = 0 # 非公開
  # 家族も無事
  FAMILY_WELL_YES     = "1" # 無事
  FAMILY_WELL_NO       = "0" # 無事であるか未確認
  # GooglePersonFinderに1度にアップロードする件数
  GPF_UPLOAD_MAX_RECORD = 100
  # 写真の最大サイズ
  MAX_PHOTO_SIZE      = 3.5.megabytes.to_i



  # maxlength validation
  validates :person_record_id,                :length => {:maximum => 500}
  validates :full_name,                       :length => {:maximum => 500}
  validates :family_name,                     :length => {:maximum => 500}
  validates :given_name,                      :length => {:maximum => 500}
  validates :alternate_names,                 :length => {:maximum => 500}
  validates :sex,                             :length => {:maximum => 1}
  validates :home_postal_code,                :length => {:maximum => 500}
  validates :in_city_flag,                    :length => {:maximum => 1}
  validates :home_state,                      :length => {:maximum => 500}
  validates :home_city,                       :length => {:maximum => 500}
  validates :home_street,                     :length => {:maximum => 500}
  validates :shelter_name,                    :length => {:maximum => 20}
  validates :refuge_status,                   :length => {:maximum => 1}
  validates :next_place,                      :length => {:maximum => 100}
  validates :next_place_phone,                :length => {:maximum => 20}
  validates :injury_flag,                     :length => {:maximum => 1}
  validates :allergy_flag,                    :length => {:maximum => 1}
  validates :pregnancy,                       :length => {:maximum => 1}
  validates :baby,                            :length => {:maximum => 1}
  validates :upper_care_level_three,          :length => {:maximum => 2}
  validates :elderly_alone,                   :length => {:maximum => 1}
  validates :elderly_couple,                  :length => {:maximum => 1}
  validates :bedridden_elderly,               :length => {:maximum => 1}
  validates :elderly_dementia,                :length => {:maximum => 1}
  validates :rehabilitation_certificate,      :length => {:maximum => 2}
  validates :physical_disability_certificate, :length => {:maximum => 1}
  validates :source_name,                     :length => {:maximum => 500}
  validates :source_url,                      :length => {:maximum => 500}

  # presence validation
  validates :author_name,        :presence => true # レコード作成者名
  validates :family_name,        :presence => true
  validates :given_name,         :presence => true

  # date validation
  validates :date_of_birth,      :date   => true
  validates :shelter_entry_date, :date   => true
  validates :shelter_leave_date, :date   => true

  # datetime validation
  validates :source_date,        :time   => true

  # format validation
  validates :age,                :allow_blank => true, :format => { :with => /^\d+(-\d+)?$/ }
  validates :author_email,       :allow_blank => true, :format => { :with => /^[^@]+@[^@]+$/ } # メールアドレス
  validates :author_phone,       :allow_blank => true, :format => { :with => /^[\-+()\d ]+$/ } # 電話番号

  # profile_urls validation
  validate :profile_urls,        :url_validater # プロフィール

  # file_size validation
  validates :photo_url,   :file_size => { :maximum => MAX_PHOTO_SIZE }


  # before_createで設定する項目
  # === Args
  # === Return
  # === Raise
  def set_attributes
    self.source_date = Time.now if self.source_date.blank?
    self.entry_date  = Time.now
    self.full_name   = "#{self.family_name} #{self.given_name}"
    self.injury_flag = self.injury_condition.present? ? INJURY_FLAG_ON : INJURY_FLAG_OFF  # 負傷の有無
    self.allergy_flag = self.allergy_cause.present? ? ALLERGY_FLAG_ON : ALLERGY_FLAG_OFF    # アレルギーの有無

    if self.home_state.present? && self.home_city.present?    # 市内・市外区分
      if self.home_state =~ /^(宮城)県?$/ && self.home_city =~ /^(石巻)市?$/
        self.in_city_flag = IN_CITY_FLAG_INSIDE  # 市内
      else
        self.in_city_flag = IN_CITY_FLAG_OUTSIDE # 市外
      end
    end

  end

  # profile_urlsの入力形式が正しい書式か？
  # === Args
  # === Return
  # boolean
  # === Raise
  def url_validater
    unless self.profile_urls.blank?
      urls = self.profile_urls.split("\n")
      urls.each do |url|
        unless  url =~ /^http(s)?:\/\/*/
          errors.add(:profile_urls, "")
          return false
        end
      end
    end
    return true
  end

  # フルネーム or よみがなに部分一致するPersonを検索する
  # === Args
  # _sp_ :: 検索条件
  # === Return
  # Personオブジェクト配列
  # === Raise
  def self.find_for_seek(sp)
    return nil if sp[:name].blank?
    
    find(:all,
      :conditions => ["(full_name LIKE :name) OR (alternate_names LIKE :name)",
        :name => "%#{sp[:name]}%"])
  end

  # 姓、名がそれぞれ部分一致 or よみがなに部分一致するPersonを抽出する
  # === Args
  # _sp_ :: 検索条件
  # === Return
  # Personオブジェクト配列
  # === Raise
  def self.find_for_provide(sp)
    return nil if sp[:family_name].blank? || sp[:given_name].blank?
    
    find(:all,
      :conditions => ["((family_name LIKE :family_name) AND (given_name LIKE :given_name)) OR
        ((alternate_names LIKE :family_name) AND (alternate_names LIKE :given_name))",
        :family_name => "%#{sp[:family_name]}%", :given_name => "%#{sp[:given_name]}%"])
  end
  

  # 対象Personが重複Noteを持っているか？
  # === Args
  # _pid_ :: Person.id
  # === Return
  # boolean
  # === Raise
  def self.check_dup(pid)
    notes = Note.find_all_by_person_record_id(pid)
    notes.each do |note|
      if note.linked_person_record_id.present?
        return true
      end
    end
    return false
  end

  # 対象のPersonと重複しているPersonを抽出する
  # === Args
  # _pid_ :: Person.id
  # === Return
  # Personオブジェクト配列
  # === Raise
  def self.duplication(pid)
    dup_notes = Note.duplication(pid) # pidが持つ重複note
    people = []
    dup_notes.each do |note|
      people << self.find_by_id(note.linked_person_record_id)
    end
    return people
  end


  # 新着メールを受け取るメールアドレスを抽出
  # === Args
  # _person_ :: Person
  # _new_note_ :: 新規Note
  # === Return
  # _to_ :: [Person, 新規Note, 送信対象のPerson or Note]
  # === Raise
  def self.subscribe_email_address(person, new_note)
    to = []
    # 送信可能なnoteを抽出する (重複無し、受取フラグ有)
    notes = Note.where(:person_record_id => person.id, :email_flag => true).where("author_email <> ?","").select("DISTINCT author_email, id")
    
    # Personが紐付くNoteのemailと重複するか判定
    # 受取フラグ有のpersonに送信する
    if person.email_flag == true
      to << [person, new_note, person]
    end
    # 受取フラグ有のnoteに送信する
    notes.each do |note|
      to << [person, new_note, note]
    end

    return to
  end

  # インポートしたpfifをPersonレコードに格納する
  # === Args
  # _person_ :: Personオブジェクト
  # _e_      :: pfif形式のPersonエレメント
  # === Return
  # Personオブジェクト
  # === Raise
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
      person.sex = "1"
    when "female"
      person.sex = "2"
    when "other"
      person.sex = "3"
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
    person.home_country      = e.elements["pfif:home_country"].try(:text)
    # CarrierWaveの記述に合わせてremote_XXX_urlの書式にしてある
    person.remote_photo_url_url = e.elements["pfif:photo_url"].try(:text)
    person.profile_urls      = e.elements["pfif:profile_urls"].try(:text)
    person.public_flag       = PUBLIC_FLAG_ON
    return person
  end

  # exportするレコードを抽出する
  # * 公開フラグがtrue
  # * 100件/xmlファイル
  # === Args
  # === Return
  # Personオブジェクト配列
  # === Raise
  def self.find_for_export_gpf
    where(:public_flag => PUBLIC_FLAG_ON, :export_flag => false).limit(GPF_UPLOAD_MAX_RECORD)
  end

end
