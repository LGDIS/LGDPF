# -*- coding:utf-8 -*-
class Note < ActiveRecord::Base
  attr_accessible :person_record_id, :liked_person_record_id, :entry_date,
    :author_name, :author_email, :author_phone, :source_date,
    :author_made_contact, :status, :email_of_found_person, :phone_of_found_person,
    :last_known_location, :text, :photo_url, :remote_photo_url_url, :spam_flag, :link_flag,
    :email_flag

  belongs_to :person, :foreign_key => "person_record_id"
  before_create :set_attributes
  mount_uploader :photo_url, PhotoUrlUploader

  # maxlength validation
  validates :note_record_id,          :length => {:maximum => 500}
  validates :linked_person_record_id, :length => {:maximum => 500}
  validates :author_name,             :length => {:maximum => 500}
  validates :author_email,            :length => {:maximum => 500}
  validates :author_phone,            :length => {:maximum => 500}
  validates :email_of_found_person,   :length => {:maximum => 500}
  validates :phone_of_found_person,   :length => {:maximum => 500}
  validates :last_known_location,     :length => {:maximum => 500}

  # presence validation
  validates :text,        :presence => true # メッセージ
  validates :author_name, :presence => true # 投稿者の名前

  # format validation
  validates :author_email, :allow_blank => true, :format => { :with => /^[^@]+@[^@]+$/ } # メールアドレス
  validates :author_phone, :allow_blank => true, :format => { :with => /^[\-+()\d ]+$/ } # 電話番号

  # datetime validation
  validates :entry_date,  :time => true
  validates :source_date, :time => true

  # author_made_contact validation
  validate :author_made_contact, :note_author_valid


  # before_createで設定する項目
  # === Args
  # === Return
  # === Raise
  def set_attributes
    self.entry_date = Time.now
  end

  # statusとauthor_made_contactの相互validation
  # * status = 3                  : 状況「私が本人である」
  # * author_made_contact = false : 連絡の有無「いいえ」
  # === Args
  # === Return
  # errorメッセージ
  # === Raise
  def note_author_valid
    if status == 3 && author_made_contact == false
      errors.add(:author_made_contact, "")
    end
  end

  # 対象Personの重複確認用のNoteを抽出する
  # === Args
  # _pid_ :: Person.id
  # === Return
  # Noteオブジェクト配列
  # === Raise
  def self.duplication(pid)
    find(:all, :conditions => ["linked_person_record_id IS NOT NULL AND person_record_id = ?", pid])
  end

  # 対象Personの重複確認用のNote以外を抽出する
  # === Args
  # _pid_ :: Person.id
  # === Return
  # Noteオブジェクト配列
  # === Raise
  def self.no_duplication(pid)
    find(:all, 
      :conditions => ["linked_person_record_id IS NULL AND person_record_id = ?", pid],
      :order => "entry_date ASC")
  end

  # Personとそれに紐付くNoteに重複するauthor_emailがあるか？
  # === Args
  # _person_ :: Personオブジェクト
  # === Return
  # boolean
  # === Raise
  def self.check_for_author_email(person)
    dup = where(:person_record_id => person.id, :author_email => person.author_email).all
    return dup.size > 0 ? true : false
  end

end