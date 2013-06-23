# -*- coding:utf-8 -*-
class TimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    before_type_cast = "#{attribute}_before_type_cast"
    raw_value = record.send(before_type_cast) if record.respond_to?(before_type_cast.to_sym)
    raw_value ||= value

    return if raw_value.blank?

    if raw_value.to_s =~ /^(\d{4})(?:\/|-|.)?(\d{1,2})(?:\/|-|.)?(\d{1,2})(?:\s{1}|T)(\d{1,2}):?(\d{1,2}):?(\d{1,2})/
      begin
        DateTime.new($1.to_i,$2.to_i,$3.to_i,$4.to_i,$5.to_i,$6.to_i)
      rescue
        record.errors[attribute] << (options[:message] || I18n.t("activerecord.errors.messages.invalid"))
      end
    else
      record.errors[attribute] << (options[:message] || I18n.t("activerecord.errors.messages.invalid"))
    end
  end
end