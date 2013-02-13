# -*- coding:utf-8 -*-
require 'spec_helper'

describe 'ApiActionLog' do
  describe 'set_attributes' do
    it 'unique_keyにidと同じ値を設定すること' do
      @aal  = ApiActionLog.create
      @aal2 = ApiActionLog.create
      @aal.unique_key.should == "0"
      @aal2.unique_key.should == @aal2.id.to_s
      @aal.entry_date.to_s.should == Time.now.to_s
    end
    it 'entry_dateに現在時刻を設定すること' do
      @aal  = ApiActionLog.create
      @aal2 = ApiActionLog.create
      @aal.entry_date.to_s.should == Time.now.to_s
      @aal2.entry_date.to_s.should == Time.now.to_s
    end
  end
end