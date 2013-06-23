# -*- coding:utf-8 -*-
require 'spec_helper'

describe 'Constant' do
  describe 'get_const' do
    context 'table_nameがPersonの場合' do
      it 'Personで利用する定数を取得できること' do
        expect = Constant.get_const("Person")
        constant_list = {}
        constant = Constant.find(:all,
          :conditions => ["kind1=? AND kind2=?", 'TD', "Person"],
          :order => "kind3 ASC, _order ASC")
        constant.each do |c|
          constant_list[c.kind3] = {} unless constant_list[c.kind3]
          constant_list[c.kind3][c.value] = c.text
        end
        constant_list.should == expect
      end
    end

        context 'table_nameがNoteの場合' do
      it 'Noteで利用する定数を取得できること' do
        expect = Constant.get_const("Note")
        constant_list = {}
        constant = Constant.find(:all,
          :conditions => ["kind1=? AND kind2=?", 'TD', "Note"],
          :order => "kind3 ASC, _order ASC")
        constant.each do |c|
          constant_list[c.kind3] = {} unless constant_list[c.kind3]
          constant_list[c.kind3][c.value] = c.text
        end
        constant_list.should == expect
      end
    end

  end
end