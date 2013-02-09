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

  validates :text, :presence => true # メッセージ
  validates :author_name, :presence => true # 投稿者の名前
  validates :author_email, :allow_blank => true, :format => { :with => /^[^@]+@[^@]+$/ } # メールアドレス
  validates :author_phone, :allow_blank => true, :format => { :with => /[\-+()\d ]+/ } # 電話番号

  validate :author_made_contact, :note_author_valid


  # before_createで設定する項目
  def set_attributes
    self.entry_date = Time.now
  end

  # statusとauthor_made_contactの相互validation
  def note_author_valid
    if status == 3 && author_made_contact == false
      errors.add(:author_made_contact, "")
    end
  end

  # 重複確認用のNoteを抽出する
  def self.duplication(pid)
    find(:all, :conditions => ["linked_person_record_id IS NOT NULL AND person_record_id = ?", pid])
  end

  # 重複確認用のNote以外を抽出する
  def self.no_duplication(pid)
    find(:all, 
      :conditions => ["linked_person_record_id IS NULL AND person_record_id = ?", pid],
      :order => "entry_date ASC")
  end

  # personとそれに紐付くnoteに重複するauthor_emailがあるかチェックする
  # === Args
  # _person_ :: 避難者
  # === Return
  # _true_ :: 重複あり
  # _false_ :: 重複無し
  #
  def self.check_for_author_email(person)
    dup = where(:person_record_id => person.id, :author_email => person.author_email).all
    return dup.size > 1 ? true : false
  end

end