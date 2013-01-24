# -*- coding:utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def get_const(table_name)
    constant_list = {}
    constant = Constant.find(:all,
      :conditions => ["kind1=? AND kind2=?", 'TD', table_name],
      :order => "kind3 ASC, _order ASC")
    constant.each do |c|
      constant_list[c.kind3] = {} unless constant_list[c.kind3]
      constant_list[c.kind3][c.value] = c.text
    end
    return constant_list
  end

  # memcacheされた値を取得・加工
  # === Args
  # _key_name_ :: キャッシュされているハッシュのキー名
  # === Return
  # _constant_list_ :: {code => name}
  #
  def get_cache(key_name)
    constant_list = {}
    constant = Rails.cache.read(key_name)
    constant.each do |c|
      constant_list[c[0]] = c[1]["name"]
    end
    return constant_list
  end
end
