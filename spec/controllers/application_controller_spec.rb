# -*- coding:utf-8 -*-
require 'spec_helper'

describe ApplicationController do
  describe '#init' do
    before do
      @app_controller = ApplicationController.new
    end
    it '定数が取得できていること' do
      @app_controller.init
      @app_controller.instance_variable_get(:@person_const).should be_present
      @app_controller.instance_variable_get(:@note_const).should be_present
    end
  end

  describe '#expiry_date' do
    before do
      @app_controller = ApplicationController.new
      @aal = ApiActionLog.create
    end
    context 'params[:token]が存在しない場合' do
      it '何もしないこと' do
        @app_controller.should_receive(:params).once.and_return({})
        @app_controller.expiry_date.should be_nil
      end
    end
    describe 'params[:token]が存在し' do
      context 'ApiActionLogに対応するキーが存在しない場合' do
        it 'raise ActiveRecord::RecordNotFound' do
          @app_controller.should_receive(:params).twice.and_return({:token => "aaa"})
          proc { @app_controller.expiry_date }.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
      describe 'ApiActionLogに対応するキーが存在し' do
        context '作成日から３日以内の場合' do
          it '何もしないこと' do
            @app_controller.should_receive(:params).twice.and_return({:token => @aal.unique_key})
            @app_controller.expiry_date.should be_nil
          end
        end
        context '作成日から３日より経過している場合' do
          it 'raise ActiveRecord::RecordNotFound' do
            @aal.entry_date = 4.days.ago
            @aal.save
            @app_controller.should_receive(:params).twice.and_return({:token => @aal.unique_key})
            proc { @app_controller.expiry_date }.should raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end

  describe "#autocomplete_city" do
    subject { get :autocomplete_city }
    before(:each) do
      request.accept = "application/json"
    end
    it { should be_success }
  end

  describe "#autocomplete_street" do
    subject { get :autocomplete_street }
    before(:each) do
      request.accept = "application/json"
    end
    it { should be_success }
  end
  
end
