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
end
