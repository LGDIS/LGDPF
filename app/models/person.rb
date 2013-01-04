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
    :public_flag

  has_many :notes
  
  before_create :set_attributes
  mount_uploader :photo_url, PhotoUrlUploader

  validates :family_name, :presence => true # 避難者_姓
  validates :given_name, :presence => true # 避難者_名
  validates :author_name, :presence => true # レコード作成者名

  
  def self.find_for_seek(sp)
    return nil if sp[:name].blank?
    
    find(:all,
      :conditions => ["(full_name LIKE :name) OR (alternate_names LIKE :name)",
        :name => "%#{sp[:name]}%"])
  end
  
  def self.find_for_provide(sp)
    return nil if sp[:family_name].blank? || sp[:given_name].blank?
    
    find(:all,
      :conditions => ["((family_name LIKE :family_name) AND (given_name LIKE :given_name)) OR
        ((alternate_names LIKE :family_name) AND (alternate_names LIKE :given_name))",
        :family_name => "%#{sp[:family_name]}%", :given_name => "%#{sp[:given_name]}%"])
  end
  
  def set_attributes
    self.source_date = Time.now
    self.entry_date  = Time.now
    self.full_name   = "#{self.family_name} #{self.given_name}"
  end
end
