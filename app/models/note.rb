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


  # --*--*-- 定数 --*--*--
  # 状況
  STATUS_UNSPECIFIED        = 1 # 指定なし
  STATUS_INFORMATION_SOUGHT = 2 # 情報を探している
  STATUS_IS_NOTE_AUTHOR     = 3 # 私が本人である
  STATUS_BELIEVED_ALIVE     = 4 # この人が生きているという情報を入手した
  STATUS_BELIEVED_MISSING   = 5 # この人を行方不明と判断した理由がある
  STATUS_BELIEVED_DEAD      = 6 # この人物が死亡したという情報を入手した

  # before_createで設定する項目
  # === Args
  # === Return
  # === Raise
  def set_attributes
    self.entry_date = Time.now
    self.source_date = Time.now if self.source_date.blank?
  end

  # statusとauthor_made_contactの相互validation
  # * status = 3                  : 状況「私が本人である」
  # * author_made_contact = false : 連絡の有無「いいえ」
  # === Args
  # === Return
  # errorメッセージ
  # === Raise
  def note_author_valid
    if status == STATUS_IS_NOTE_AUTHOR && author_made_contact == false
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

  # pfifをNoteレコードに格納する
  # === Args
  # _note_ :: Noteオブジェクト
  # _e_    :: pfif形式のNoteエレメント
  # === Return
  # Noteオブジェクト
  # === Raise
  def self.exec_insert_note(note, e)
    note.note_record_id         = e.elements["pfif:note_record_id"].try(:text)
    person_record               = Person.with_deleted.find_by_person_record_id(e.elements["pfif:person_record_id"].try(:text))
    note.person_record_id       = person_record.id if person_record.present?
    linked_person_record        = Person.with_deleted.find_by_person_record_id(e.elements["pfif:linked_person_record_id"].text) if e.elements["pfif:linked_person_record_id"].present?
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
    when "information_sought"     # 情報を探している
      status = STATUS_INFORMATION_SOUGHT
    when "is_note_author"         # 私が本人である
      status = STATUS_IS_NOTE_AUTHOR
    when "believed_alive"         # この人が生きているという情報を入手した
      status = STATUS_BELIEVED_ALIVE
    when "believed_missing"       # この人を行方不明と判断した理由がある
      status = STATUS_BELIEVED_MISSING
    when "believed_dead"          # この人物が死亡したという情報を入手した
      status = STATUS_BELIEVED_DEAD
    else
      status = STATUS_UNSPECIFIED # 指定無し
    end
    note.status                 = status
    note.email_of_found_person  = e.elements["pfif:email_of_found_person"].try(:text)
    note.phone_of_found_person  = e.elements["pfif:phone_of_found_person"].try(:text)
    note.last_known_location    = e.elements["pfif:last_known_location"].try(:text)
    note.text                   = e.elements["pfif:text"].try(:text)
    note.remote_photo_url_url   = e.elements["pfif:photo_url"].try(:text)

    return note
  end


end