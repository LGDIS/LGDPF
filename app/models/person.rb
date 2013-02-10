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
    :profile_urls

  has_many :notes

  acts_as_paranoid
  # newレコードをsaveした場合の処理
  before_create :set_attributes
  mount_uploader :photo_url, PhotoUrlUploader

  validates :family_name, :presence => true # 避難者_姓
  validates :given_name, :presence => true # 避難者_名
  validates :author_name, :presence => true # レコード作成者名
  validates :age, :allow_blank => true, :format => { :with => /^\d+(-\d+)?$/ } # 年齢
  validates :author_email, :allow_blank => true, :format => { :with => /^[^@]+@[^@]+$/ } # メールアドレス
  validates :author_phone, :allow_blank => true, :format => { :with => /^[\-+()\d ]+$/ } # 電話番号
  validates :date_of_birth, :date => true # 生年月日
  validates :source_date, :time => true # 投稿日
  validate :profile_urls, :url_validater # プロフィール

  # before_createで設定する項目
  def set_attributes
    self.source_date = Time.now if self.source_date.blank?
    self.entry_date  = Time.now
    self.full_name   = "#{self.family_name} #{self.given_name}"
    self.injury_flag = self.injury_condition.present? ? 1:0  # 負傷の有無
    self.allergy_flag = self.allergy_cause.present? ? 1:0   # アレルギーの有無

    if self.home_state.present? && self.home_city.present?  # 市内・市外区分
      if self.home_state =~ /^(宮城)県?$/ && self.home_city =~ /^(石巻)市?$/
        self.in_city_flag = 1  # 市内
      else
        self.in_city_flag = 0  # 市外
      end
    end

  end

  # 入力値チェック
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

  # 避難者を検索する
  # ==== Args
  # _sp_ :: 検索条件
  #
  def self.find_for_seek(sp)
    return nil if sp[:name].blank?
    
    find(:all,
      :conditions => ["(full_name LIKE :name) OR (alternate_names LIKE :name)",
        :name => "%#{sp[:name]}%"])
  end

  # 情報提供する避難者情報が既に登録されているか確認する
  # ==== Args
  # _sp_ :: 検索条件
  #
  def self.find_for_provide(sp)
    return nil if sp[:family_name].blank? || sp[:given_name].blank?
    
    find(:all,
      :conditions => ["((family_name LIKE :family_name) AND (given_name LIKE :given_name)) OR
        ((alternate_names LIKE :family_name) AND (alternate_names LIKE :given_name))",
        :family_name => "%#{sp[:family_name]}%", :given_name => "%#{sp[:given_name]}%"])
  end
  

  # 重複Noteを持っているか確認する
  # === Args
  # _pid_ :: 避難者id
  #
  def self.check_dup(pid)
    notes = Note.find_all_by_person_record_id(pid)
    notes.each do |note|
      if note.linked_person_record_id.present?
        return true
      end
    end
    return false
  end

  # 重複するpersonを抽出する
  # === Args
  # _pid_ :: 避難者id
  #
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
  # _to_ :: [person, new_note, 送信対象のperson or note]
  #
  def self.subscribe_email_address(person, new_note)
    to = []
    # 送信可能なnote
    # 重複無し、受取フラグ有
    notes = Note.where(:person_record_id => person.id, :email_flag => true).where("author_email <> ?","").select("DISTINCT author_email, id")
    
    # Personが紐付くNoteのemailと重複するか判定
    notes.each do |note|
      if person.author_email == note.author_email && person.email_flag == true
        to << [person, new_note, person]
      else
        to << [person, new_note, note]
      end
    end

    return to
  end

end
