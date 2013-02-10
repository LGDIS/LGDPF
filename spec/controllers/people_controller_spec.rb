# -*- coding:utf-8 -*-
require 'spec_helper'


describe PeopleController do

  before(:each) do
    @person = FactoryGirl.create(:person)
    @params = {
      :id => @person.id
    }
  end

  describe '#index' do
    describe 'GET' do
      before do
        get :index
      end
      it 'リクエストが成功すること' do
        response.should be_success
      end
      it "トップ画面を描画すること" do
        response.should render_template("index")
      end

    end
  end

  describe '#seek' do
    describe 'GET' do
      before do
        get :seek
      end
      it 'リクエストが成功すること' do
        response.should be_success
      end
      it "検索画面を描画すること" do
        response.should render_template("seek")
      end
    end
    describe 'POST' do
      it 'リクエストが成功すること' do
        post :seek, :role => "first_step", :name => ""
        response.should be_success
      end
      it "検索画面を描画すること" do
        post :seek, :role => "first_step", :name => ""
        response.should render_template("seek")
      end
      context '検索条件が未入力の場合' do
        before do
          post :seek, :role => "first_step", :name => ""
        end

        it "flashメッセージが表示されること" do
          flash[:error].should == I18n.t("activerecord.errors.messages.seek_blank")
        end
      end
      context '検索条件に入力がある場合' do
        before do
          post :seek, :role => "first_step", :name => "東京"
        end
        it '検索されること' do
          assigns[:person].should be_present
        end
      end
      
    end
  end

  describe '#provide' do
    describe 'GET' do
      before do
        get :provide
      end
      it 'リクエストが成功すること' do
        response.should be_success
      end
      it "安否情報対象者入力画面を描画すること" do
        response.should render_template("provide")
      end
    end

    describe 'POST' do
      describe '検索条件に入力がある' do
        context "検索結果がある場合" do
          before do
            post :provide, :role => "first_step", :family_name => "東京", :given_name => "一郎"
          end
          it 'リクエストが成功すること' do
            response.should be_success
          end
          it "安否情報対象者入力画面を描画すること" do
            response.should render_template("provide")
          end          
        end

        context "検索結果がない場合" do
          before do
            post :provide, :role => "first_step", :family_name => "東京", :given_name => "二郎"
          end
          it "安否情報提供画面を描画すること" do
            response.should be_redirect
            response.should redirect_to(:action => "new",
              :family_name => "東京", :given_name  => "二郎")
          end          
        end
        
      end
      describe '検索条件が未入力' do
        before do
          post :provide, :role => "first_step", :family_name => "", :given_name => ""
        end
        it 'リクエストが成功すること' do
          response.should be_success
        end
        it "安否情報対象者入力画面を描画すること" do
          response.should render_template("provide")
        end
        it "flashメッセージが表示されること" do
          flash[:error].should == I18n.t("activerecord.errors.messages.provide_blank")
        end
      end
  
    end
  end

  describe '#multiviews' do
    describe 'POST' do
      before do
        @person1 = FactoryGirl.create(:person)
        @person2 = FactoryGirl.create(:person)
        @person3 = FactoryGirl.create(:person)
      end
      context '重複件数が2件の場合' do
        it '避難者情報重複確認画面が描画されること' do
          post :multiviews, {:id1 => @person1.id, :id2 => @person2.id, :mark_count => 2}

          assigns[:count].should be_present
          assigns[:person].should be_present
          assigns[:person2].should be_present
          assigns[:person3].should be_blank
          assigns[:note].should be_present
          assigns[:subscribe].should be_false
          response.should be_success
          response.should render_template("multiviews")
        end
      end

      context '重複件数が3件の場合' do
        it '避難者情報重複確認画面が描画されること' do
          post :multiviews, :id1 => @person1.id,
            :id2 => @person2.id,
            :id3 => @person3.id,
            :mark_count => 3

          assigns[:count].should be_present
          assigns[:person].should be_present
          assigns[:person2].should be_present
          assigns[:person3].should be_present
          assigns[:note].should be_present
          assigns[:subscribe].should be_false
          response.should be_success
          response.should render_template("multiviews")
        end
      end

    end
  end

  describe '#dup_merge' do
    describe 'POST' do
      before do
        @person2 = FactoryGirl.create(:person)
        @person3 = FactoryGirl.create(:person)
        @note    = FactoryGirl.create(:note)
        LgdpfMailer.stub_chain(:send_add_note, :deliver)
      end
      describe '重複件数が2件' do
        context '必須項目が未入力の場合' do
          it 'flashメッセージが表示されること' do
            post :dup_merge,
              :person => {:id => @person.id},
              :person2 => {:id => @person2.id},
              :person3 => {:id => ""},
              :note => {:text => ""},
              :count => 3

            assigns[:consent].should be_false
            assigns[:note].should be_present
            assigns[:note2].should be_present
            assigns[:note3].should be_blank
            assigns[:note].errors.messages.should be_present
            response.should be_success
            response.should render_template("multiviews")
          end
        end
        describe '必須項目が入力' do
          context '利用規約に同意していない場合' do
            it 'flashメッセージが表示されること' do
              post :dup_merge,
                :person => {:id => @person.id},
                :person2 => {:id => @person2.id},
                :person3 => {:id => ""},
                :note => {:text => "メッセージ", :author_name => "投稿者"},
                :count => 3

              assigns[:consent].should be_false
              assigns[:note].should be_present
              assigns[:note2].should be_present
              assigns[:note3].should be_blank
              flash[:error].should == I18n.t("activerecord.errors.messages.disagree")
              response.should be_success
              response.should render_template("multiviews")
            end
          end
          describe '利用規約に同意している' do
            context '新着情報を受け取るにチェックがある場合' do
              it '新着情報受信許可画面に遷移すること' do
                post :dup_merge,
                  :person => {:id => @person.id},
                  :person2 => {:id => @person2.id},
                  :person3 => {:id => ""},
                  :note => {:text => "メッセージ", :author_name => "投稿者"},
                  :count => 3,
                  :consent => "true",
                  :subscribe => "true"

                assigns[:consent].should be_true
                assigns[:note].should be_present
                assigns[:note2].should be_present
                assigns[:note3].should be_blank
                response.should be_redirect
                response.should redirect_to :action => "subscribe_email",
                  :id => @person.id,
                  :id2 => @person2.id,
                  :note_id => assigns[:note].id,
                  :note_id2 => assigns[:note2].id
              end
            end
            context '新着情報を受け取るにチェックがない場合' do
              it '人物情報登録確認画面に遷移すること' do
                post :dup_merge,
                  :person => {:id => @person.id},
                  :person2 => {:id => @person2.id},
                  :person3 => {:id => ""},
                  :note => {:text => "メッセージ", :author_name => "投稿者"},
                  :count => 3,
                  :consent => "true",
                  :subscribe => ""

                assigns[:consent].should be_true
                assigns[:note].should be_present
                assigns[:note2].should be_present
                assigns[:note3].should be_blank
                response.should be_redirect
                response.should redirect_to(:action => 'view',
                  :id => assigns[:person].id)
              end
            end
          end
        end
      end

      describe '重複件数が3件' do
        context '必須項目が未入力の場合' do
          it 'flashメッセージが表示されること' do
            post :dup_merge,
              :person => {:id => @person.id},
              :person2 => {:id => @person2.id},
              :person3 => {:id => @person3.id},
              :note => {:text => ""},
              :count => 4

            assigns[:consent].should be_false
            assigns[:note].should be_present
            assigns[:note2].should be_present
            assigns[:note3].should be_present
            assigns[:note].errors.messages.should be_present
            response.should be_success
            response.should render_template("multiviews")
          end
        end
        describe '必須項目が入力' do
          context '利用規約に同意していない場合' do
            it 'flashメッセージが表示されること' do
              post :dup_merge,
                :person => {:id => @person.id},
                :person2 => {:id => @person2.id},
                :person3 => {:id => @person3.id},
                :note => {:text => "メッセージ", :author_name => "投稿者"},
                :count => 4

              assigns[:consent].should be_false
              assigns[:note].should be_present
              assigns[:note2].should be_present
              assigns[:note3].should be_present
              flash[:error].should == I18n.t("activerecord.errors.messages.disagree")
              response.should be_success
              response.should render_template("multiviews")
            end
          end
          describe '利用規約に同意している' do
            context '新着情報を受け取るにチェックがある場合' do
              it '新着情報受信許可画面に遷移すること' do
                post :dup_merge,
                  :person => {:id => @person.id},
                  :person2 => {:id => @person2.id},
                  :person3 => {:id => @person3.id},
                  :note => {:text => "メッセージ", :author_name => "投稿者"},
                  :count => 4,
                  :consent => "true",
                  :subscribe => "true"

                assigns[:consent].should be_true
                assigns[:note].should be_present
                assigns[:note2].should be_present
                assigns[:note3].should be_present
                response.should be_redirect
                response.should redirect_to :action => "subscribe_email",
                  :id => @person.id,
                  :id2 => @person2.id,
                  :id3 => @person3.id,
                  :note_id => assigns[:note].id,
                  :note_id2 => assigns[:note2].id,
                  :note_id3 => assigns[:note3].id
              end
            end
            context '新着情報を受け取るにチェックがない場合' do
              it '人物情報登録確認画面に遷移すること' do
                post :dup_merge,
                  :person => {:id => @person.id},
                  :person2 => {:id => @person2.id},
                  :person3 => {:id => @person3.id},
                  :note => {:text => "メッセージ", :author_name => "投稿者"},
                  :count => 4,
                  :consent => "true",
                  :subscribe => ""

                assigns[:consent].should be_true
                assigns[:note].should be_present
                assigns[:note2].should be_present
                assigns[:note3].should be_present
                response.should be_redirect
                response.should redirect_to(:action => 'view',
                  :id => assigns[:person].id)
              end
            end
          end
        end

      end
    end
  end

  describe '#new' do
    describe 'GET' do
      describe 'パラメータの設定' do
        context '検索画面から遷移してきた場合' do
          before do
            get :new
          end
          it '遷移元フラグが検索画面であること' do
            assigns[:from_seek].should be_present
          end
          it '名前が設定されないこと' do
            assigns[:person][:family_name].should be_blank
            assigns[:person][:given_name].should be_blank
          end
          it 'リクエストが成功すること' do
            response.should be_success
          end
          it "避難者情報重複確認画面を描画すること" do
            response.should render_template("new")
          end
        end

        context '安否情報対象者入力画面から遷移してきた場合' do
          before do
            get :new, :family_name => "東京", :given_name => "一郎"
          end
          it '遷移元フラグが安否情報対象者入力画面であること' do
            assigns[:from_seek].should be_nil
          end
          it '名前が設定されること' do
            assigns[:person][:family_name].should == "東京"
            assigns[:person][:given_name].should == "一郎"
          end
          it 'リクエストが成功すること' do
            response.should be_success
          end
          it "避難者情報重複確認画面を描画すること" do
            response.should render_template("new")
          end
        end

      end

    end
  end

  describe '#create' do
    describe 'POST' do
      describe '検索画面から遷移してきた画面' do
        context '必須項目が未入力の場合' do
          it 'flashメッセージが表示されること' do
            post :create, :person => {:given_name => "登録", :author_name => "投稿者"},
              :clone => {:clone_input => "no"}

            assigns[:consent].should be_false
            assigns[:person].errors.messages.should be_present
            response.should be_success
            response.should render_template("new")
          end
        end
        describe '必須項目が入力' do
          context '利用規約に同意していない場合' do
            it 'flashメッセージが表示されること' do
              post :create,
                :person => {:family_name => "新規", :given_name => "登録", :author_name => "投稿者"},
                :clone => {:clone_input => "no"}

              assigns[:consent].should be_false
              flash[:error].should == I18n.t("activerecord.errors.messages.disagree")
              response.should be_success
              response.should render_template("new")
            end
          end
          describe '利用規約に同意している' do
            context '新着情報を受け取るにチェックがある場合' do
              it '新着情報受信許可画面に遷移すること' do
                post :create,
                  :person => {:family_name => "新規", :given_name => "登録", :author_name => "投稿者"},
                  :clone => {:clone_input => "no"},
                  :consent => "true",
                  :subscribe => "true"

                response.should be_redirect
                response.should redirect_to(:action => 'subscribe_email',
                  :id => assigns[:person].id)
              end
            end
            context '新着情報を受け取るにチェックがない場合' do
              it '人物情報登録確認画面に遷移すること' do
                post :create,
                  :person => {:family_name => "新規", :given_name => "登録", :author_name => "投稿者"},
                  :clone => {:clone_input => "no"},
                  :consent => "true",
                  :subscribe => ""

                response.should be_redirect
                response.should redirect_to(:action => 'view',
                  :id => assigns[:person].id)
              end
            end
          end
        end
      end

      describe '安否情報対象者入力画面から遷移してきた画面' do
        context '必須項目が未入力の場合' do
          it 'flashメッセージが表示されること' do
            post :create,
              :person => {:family_name => "新規", :given_name => "登録", :author_name => "投稿者"},
              :note => {:text => ""},
              :clone => {:clone_input => "no"},
              :clickable_map => {:location_field => nil}

            assigns[:from_seek].should be_false
            assigns[:consent].should be_false
            assigns[:note].should be_present
            assigns[:note].errors.messages.should be_present
            response.should be_success
            response.should render_template("new")
          end
        end
        describe '必須項目が入力' do
          context '利用規約に同意していない場合' do
            it 'flashメッセージが表示されること' do
              post :create,
                :person => {:family_name => "新規", :given_name => "登録", :author_name => "投稿者"},
                :note => {:text => "メッセージ"},
                :clone => {:clone_input => "no"},
                :clickable_map => {:location_field => nil}

              assigns[:from_seek].should be_false
              assigns[:consent].should be_false
              assigns[:note].should be_present
              flash[:error].should == I18n.t("activerecord.errors.messages.disagree")
              response.should be_success
              response.should render_template("new")
            end
          end
          describe '利用規約に同意している' do
            context '新着情報を受け取るにチェックがある場合' do
              it '新着情報受信許可画面に遷移すること' do
                post :create,
                  :person => {:family_name => "新規", :given_name => "登録", :author_name => "投稿者"},
                  :note => {:text => "メッセージ"},
                  :clone => {:clone_input => "no"},
                  :clickable_map => {:location_field => nil},
                  :consent => "true",
                  :subscribe => "true"

                assigns[:from_seek].should be_false
                assigns[:consent].should be_true
                assigns[:note].should be_present
                response.should be_redirect
                response.should redirect_to(:action => 'subscribe_email',
                  :id => assigns[:person].id)
              end
            end
            context '新着情報を受け取るにチェックがない場合' do
              it '人物情報登録確認画面に遷移すること' do
                post :create,
                  :person => {:family_name => "新規", :given_name => "登録", :author_name => "投稿者"},
                  :note => {:text => "メッセージ"},
                  :clone => {:clone_input => "no"},
                  :clickable_map => {:location_field => nil},
                  :consent => "true",
                  :subscribe => ""

                assigns[:from_seek].should be_false
                assigns[:consent].should be_true
                assigns[:note].should be_present
                response.should be_redirect
                response.should redirect_to(:action => 'view',
                  :id => assigns[:person].id)
              end
            end
          end
        end
      end

    end
  end

  describe '#view' do
    describe 'GET' do
      context '検索画面から遷移してきた場合' do
        before do
          get :view, :id => @person.id,
            :role => "seek",
            :name => "東京"
        end
        it '人物情報登録確認画面が描画されること' do
          response.should be_success
          response.should render_template("view")
          assigns[:person].should be_present
        end
        it '遷移元フラグが検索一覧であること' do
          assigns[:query].should == "東京"
          assigns[:query_family].should be_nil
          assigns[:query_given].should be_nil
          assigns[:action].should == "seek"

        end
        it 'sessionにアクション名が保存されること' do
          session[:action].should == "view"
        end
      end

      context '安否情報対象者入力画面から遷移してきた場合' do
        before do
          get :view, :id => @person.id,
            :role => "provide",
            :family_name => "東京",
            :given_name => "一郎"
        end
        it '人物情報登録確認画面が描画されること' do
          response.should be_success
          response.should render_template("view")
          assigns[:person].should be_present
        end
        it '遷移元フラグが検索一覧であること' do
          assigns[:query].should be_nil
          assigns[:query_family].should == "東京"
          assigns[:query_given].should == "一郎"
          assigns[:action].should == "provide"
        end
        it 'sessionにアクション名が保存されること' do
          session[:action].should == "view"
        end
      end

      context '重複をマークしたメモを表示モードの場合' do
        before do
          @note = FactoryGirl.create(:note)
          @person_have_note = Person.find_by_id(@note.person_record_id)
          get :view, :id => @person_have_note.id, :duplication => "true"
        end
        it '人物情報登録確認画面が描画されること' do
          response.should be_success
          response.should render_template("view")
          assigns[:person].should be_present
          assigns[:notes].should be_present
        end
        it 'sessionにアクション名が保存されること' do
          session[:action].should == "view"
        end
      end

      context '登録画面、直接入力で遷移してきた場合' do
        before do
          get :view, :id => @person.id
        end
        it '人物情報登録確認画面が描画されること' do
          response.should be_success
          response.should render_template("view")
          assigns[:person].should be_present
        end
        it 'sessionにアクション名が保存されること' do
          session[:action].should == "view"
        end
      end

    end
  end

  describe '#update' do
    describe 'POST' do
      context '「有効期限を60日延長する」ボタンを押下した場合' do
        it '避難者情報保持期間延長画面に遷移すること' do
          post :update, :id => @person.id,
            :extend_days => "有効期限"

          response.should be_redirect
          response.should redirect_to(:action => :extend_days, :id => assigns[:person].id)
        end
      end

      context '「この方の新着情報をメールで受け取る」ボタンを押下した場合' do
        it '新着情報受信許可画面に遷移すること' do
          post :update, :id => @person.id,
            :subscribe_email => "新着メール"

          response.should be_redirect
          response.should redirect_to(:action => :subscribe_email, :id => assigns[:person].id)
        end
      end

      context '「このレコードを削除する」ボタンを押下した場合' do
        it '避難者情報削除画面に遷移すること' do
          post :update, :id => @person.id,
            :delete => "削除"

          response.should be_redirect
          response.should redirect_to(:action => :delete, :id => assigns[:person].id)
        end
      end

      context '「この記録へのメモの書き込みを禁止する」ボタンを押下した場合' do
        it '安否情報登録無効申請画面に遷移すること' do
          post :update, :id => @person.id,
            :note_invalid_apply => "メモ無効"

          response.should be_redirect
          response.should redirect_to(:action => :note_invalid_apply, :id => assigns[:person].id)
        end
      end

      context '「この記録へのメモの書き込みを許可する」ボタンを押下した場合' do
        it '安否情報登録有効申請画面に遷移すること' do
          post :update, :id => @person.id,
            :note_valid_apply => "メモ有効"

          response.should be_redirect
          response.should redirect_to(:action => :note_valid_apply, :id => assigns[:person].id)
        end
      end

      describe '「この記録を保存」ボタンを押下' do
        context '必須項目が未入力の場合' do
          it 'flashメッセージが表示されること' do
            post :update,
              :id => @person.id,
              :note => {:text => ""},
              :clickable_map => {:location_field => nil}

            assigns[:consent].should be_false
            assigns[:note].should be_present
            assigns[:note].errors.messages.should be_present
            response.should be_success
            response.should render_template("view")
          end
        end
        describe '必須項目が入力' do
          context '利用規約に同意していない場合' do
            it 'flashメッセージが表示されること' do
              post :update,
                :id => @person.id,
                :note => {:text => "メッセージ", :author_name => "投稿者"},
                :clickable_map => {:location_field => nil}

              assigns[:consent].should be_false
              assigns[:note].should be_present
              flash[:error].should == I18n.t("activerecord.errors.messages.disagree")
              response.should be_success
              response.should render_template("view")
            end
          end
          describe '利用規約に同意している' do
            context '新着情報を受け取るにチェックがある場合' do
              it '新着情報受信許可画面に遷移すること' do
                post :update,
                  :id => @person.id,
                  :note => {:text => "メッセージ", :author_name => "投稿者"},
                  :clickable_map => {:location_field => nil},
                  :consent => "true",
                  :subscribe => "true"

                assigns[:consent].should be_true
                assigns[:note].should be_present
                response.should be_redirect
                response.should redirect_to(:action => :subscribe_email,
                  :id => assigns[:person].id,
                  :note_id => assigns[:note].id)
              end
            end
            context '新着情報を受け取るにチェックがない場合' do
              it '人物情報登録確認画面に遷移すること' do
                post :update,
                  :id => @person.id,
                  :note => {:text => "メッセージ", :author_name => "投稿者"},
                  :clickable_map => {:location_field => nil},
                  :consent => "true",
                  :subscribe => ""

                assigns[:consent].should be_true
                assigns[:note].should be_present
                response.should be_redirect
                response.should redirect_to(:action => 'view',
                  :id => assigns[:person].id)
              end
            end
          end
        end


      end
      
    end
  end

  describe '#extend_days' do
    before do
      @person = FactoryGirl.create(:person, :expiry_date => Time.now)
    end
    describe 'GET' do
      it '避難者情報保持期間延長画面が描画されること' do
        get :extend_days, :id => @person.id
        response.should be_success
        response.should render_template(:extend_days)
      end
    end

    describe 'POST' do
      it '人物情報登録確認画面へ遷移すること' do
        post :extend_days,
          :id => @person.id,
          :commit => "OK"
        
        response.should be_redirect
        response.should redirect_to(:action => :complete,
          :id => assigns[:person].id,
          :complete => {:key => "extend_days"})
      end
    end

  end

  describe '#subscribe_email' do
    before do
      @person2 = FactoryGirl.create(:person)
      @person3 = FactoryGirl.create(:person)
      @note    = FactoryGirl.create(:note)
      @note2   = FactoryGirl.create(:note)
      @note3   = FactoryGirl.create(:note)
    end
    describe 'GET' do
      context '安否情報提供画面から遷移してきた場合' do
        it '新着情報受信許可画面を描画すること' do
          get :subscribe_email, :id => @person.id
          response.should be_success
          response.should render_template(:subscribe_email)
        end
      end

      context '人物情報登録確認画面から遷移してきた場合' do
        it '新着情報受信許可画面を描画すること' do
          @note    = FactoryGirl.create(:note)
          get :subscribe_email, :id => @person.id, :note_id => @note.id
          response.should be_success
          response.should render_template(:subscribe_email)
        end
      end

      context '避難者情報重複確認画面から遷移してきた場合' do
        it '新着情報受信許可画面を描画すること' do
          get :subscribe_email,
            :id       => @person,
            :id2      => @person2,
            :id3      => @person3,
            :note_id  => @note,
            :note_id2 => @note2,
            :note_id3 => @note3
          response.should be_success
          response.should render_template(:subscribe_email)
        end
      end
    end

    describe 'POST' do
      describe '安否情報提供画面から遷移してきた場合' do
        describe 'アップデートを受け取るボタン押下' do
          let(:params_from_seek) do
            {
              :success => "OK",
              :person  => {:author_email => ""},
              :id      => @person
            }
          end
          let(:params_from_provide) do
            {
              :success => "OK",
              :note    => {:author_email => ""},
              :id      => @person,
              :note_id => @note
            }
          end
          context 'メールアドレスが未入力の場合' do
            it '新着情報受信許可画面へ遷移すること(seek)' do
              post :subscribe_email, params_from_seek

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_blank
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank

              response.should be_success
              flash[:error].should == I18n.t("activerecord.errors.messages.email_blank")
              response.should render_template(:subscribe_email)
            end

            it '新着情報受信許可画面へ遷移すること(provide)' do
              post :subscribe_email, params_from_provide

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_present
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank

              response.should be_success
              flash[:error].should == I18n.t("activerecord.errors.messages.email_blank")
              response.should render_template(:subscribe_email)
            end
          end

          context 'メールアドレスが入力不正の場合' do
            it '新着情報受信許可画面へ遷移すること(seek)' do
              params_from_seek[:person][:author_email] = "aaa"
              post :subscribe_email, params_from_seek

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_blank
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank
              assigns[:person].errors.messages[:author_email][0].should == I18n.t("activerecord.errors.messages.invalid")

              response.should be_success
              response.should render_template(:subscribe_email)
            end

            it '新着情報受信許可画面へ遷移すること(provide)' do
              params_from_provide[:note][:author_email] = "aaa"
              post :subscribe_email, params_from_provide

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_present
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank
              assigns[:note].errors.messages[:author_email][0].should == I18n.t("activerecord.errors.messages.invalid")

              response.should be_success
              response.should render_template(:subscribe_email)
            end
          end

          context 'メールアドレスが正しく入力されている場合' do
            before do
              LgdpfMailer.stub_chain(:send_new_information, :deliver)
            end
            it '人物情報登録確認画面へ遷移すること(seek)' do
              params_from_seek[:person][:author_email] = "aaa@test.jp"
              post :subscribe_email, params_from_seek

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_blank
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank

              response.should be_redirect
              response.should redirect_to(:action => :complete,
                :id => @person.id,
                :complete => {:key => "subscribe_email"})
            end
            it '人物情報登録確認画面へ遷移すること(provide)' do
              params_from_provide[:note][:author_email] = "aaa@test.jp"
              post :subscribe_email, params_from_provide

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_present
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank

              response.should be_redirect
              response.should redirect_to(:action => :complete,
                :id => @person.id,
                :complete => {:key => "subscribe_email"})
            end
          end
        end
      end

      describe '人物情報登録確認画面から遷移してきた場合' do
        describe 'アップデートを受け取るボタン押下' do
          let(:params) do
            {
              :success => "OK",
              :person  => {:author_email => ""},
              :note    => {:author_email => ""},
              :id      => @person,
              :note_id => @note
            }
          end
          context 'メールアドレスが未入力の場合' do
            it '新着情報受信許可画面へ遷移すること' do
              post :subscribe_email, params

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_present
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank

              response.should be_success
              flash.now[:error].should == I18n.t("activerecord.errors.messages.email_blank")
              response.should render_template(:subscribe_email)
            end
          end

          context 'メールアドレスが入力不正の場合' do
            it '新着情報受信許可画面へ遷移すること' do
              params[:note][:author_email] = "aaa"
              post :subscribe_email, params

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_present
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank
              assigns[:note].errors.messages[:author_email][0].should == I18n.t("activerecord.errors.messages.invalid")

              response.should be_success
              response.should render_template(:subscribe_email)
            end
          end
            
          context 'メールアドレスが正しく入力されている場合' do
            before do
              LgdpfMailer.stub_chain(:send_new_information, :deliver)
            end
            it '人物情報登録確認画面へ遷移すること' do
              params[:note][:author_email] = "aaa@test.jp"
              post :subscribe_email, params

              assigns[:person].should be_present
              assigns[:person2].should be_blank
              assigns[:person3].should be_blank
              assigns[:note].should be_present
              assigns[:note2].should be_blank
              assigns[:note3].should be_blank

              response.should be_redirect
              response.should redirect_to(:action => :complete,
                :id => @person.id,
                :complete => {:key => "subscribe_email"})
            end
          end
         
        end
      end

      describe '避難者情報重複確認画面から遷移してきた場合' do
        describe 'アップデートを受け取るボタン押下' do
          let(:params)do
            {
              :success => "OK",
              :person => {:author_email => ""},
              :note => {:author_email => ""},
              :id => @person,
              :id2 => @person2,
              :id3 => @person3,
              :note_id => @note,
              :note_id2 => @note2,
              :note_id3 => @note3
            }
          end
          context 'メールアドレスが未入力の場合' do
            it '新着情報受信許可画面へ遷移すること' do
              post :subscribe_email, params
              assigns[:person].should be_present
              assigns[:person2].should be_present
              assigns[:person3].should be_present
              assigns[:note].should be_present
              assigns[:note2].should be_present
              assigns[:note3].should be_present

              response.should be_success
              flash[:error].should == I18n.t("activerecord.errors.messages.email_blank")
              response.should render_template(:subscribe_email)

            end
          end
          context 'メールアドレスが不正の場合' do
            it '新着情報受信許可画面へ遷移すること' do
              params[:note][:author_email] = "aaa"
              post :subscribe_email, params
              assigns[:person].should be_present
              assigns[:person2].should be_present
              assigns[:person3].should be_present
              assigns[:note].should be_present
              assigns[:note2].should be_present
              assigns[:note3].should be_present
              assigns[:note].errors.messages[:author_email][0].should == I18n.t("activerecord.errors.messages.invalid")

              response.should be_success
              response.should render_template(:subscribe_email)

            end
          end
          context 'メールアドレスが正しく入力されている場合' do
            before do
              LgdpfMailer.stub_chain(:send_new_information, :deliver)
            end
            it '人物情報登録確認画面へ遷移すること' do
              params[:note][:author_email] = "aaa@test.jp"
              post :subscribe_email, params
              assigns[:person].should be_present
              assigns[:person2].should be_present
              assigns[:person3].should be_present
              assigns[:note].should be_present
              assigns[:note2].should be_present
              assigns[:note3].should be_present

              response.should be_redirect
              response.should redirect_to(:action => :complete,
                :id => @person.id,
                :complete => {:key => "subscribe_email"})
            end
          end

        end
      end


    end
  end

  describe '#unsubscribe_email' do
    describe 'GET' do
      context 'Personの新着情報の受信を停止する場合' do
        it '設定変更完了画面へ遷移すること' do
          get :unsubscribe_email, :id => @person.id

          assigns[:person].should be_present
          assigns[:note].should be_blank

          response.should be_redirect
          response.should redirect_to :action => :complete,
            :id => @person.id,
            :complete => {:key => "unsubscribe_email"}
        end
      end

      context 'Noteの新着情報の受信を停止する場合' do
        it '設定変更完了画面へ遷移すること' do
          @note = FactoryGirl.create(:note, :email_flag => true)
          get :unsubscribe_email, :id => @person.id, :note_id => @note.id

          assigns[:person].should be_present
          assigns[:note].should be_present

          response.should be_redirect
          response.should redirect_to :action => :complete,
            :id => @person.id,
            :complete => {:key => "unsubscribe_email"}
        end
      end

    end
  end

  describe '#delete' do
    describe 'GET' do
      it '避難者情報削除画面が描画されること' do
        get :delete, :id => @person.id
        response.should be_success
        response.should render_template(:delete)
      end
    end

    describe 'POST' do
      before do
        LgdpfMailer.stub_chain(:send_delete_notice, :deliver)
      end
      it '設定変更画面へ遷移すること' do
        post :delete,
          :id => @person.id,
          :commit => "OK"

        response.should be_redirect
        response.should redirect_to(:action => :complete,
          :id => assigns[:person].id,
          :complete => {:key => "delete"})
      end
    end
  end

  describe '#restore' do
    describe 'GET' do
      context 'DBに存在しないパラメータを渡された場合' do
        before do
          @person = FactoryGirl.create(:person)
        end
        it '404のエラー画面が描画されること' do
          get :restore, :id => 1
          response.should be_success
          response.should render_template(:file => "#{Rails.root}/public/404.html")
        end
      end
      context 'レコードが削除されている場合' do
        before do
          @person = FactoryGirl.create(:person, :deleted_at => Time.now)
        end
        it '避難者情報削除画面が描画されること' do
          get :restore, :id => @person.id
          response.should be_success
          response.should render_template(:restore)
        end
      end

      context 'レコードが復元されている場合' do
        before do
          @person = FactoryGirl.create(:person, :deleted_at => nil)
        end
        it '人物情報登録確認画面が描画されること' do
          get :restore, :id => @person.id
          response.should be_redirect
          response.should redirect_to(:action => :view, :id => @person.id)
        end
      end

    end

    describe 'POST' do
      before do
        LgdpfMailer.stub_chain(:send_restore_notice, :deliver)
      end
      it '人物情報登録確認画面へ遷移すること' do
        post :restore,
          :id => @person.id,
          :commit => "OK"

        response.should be_redirect
        response.should redirect_to(:action => :view, :id => @person.id)
      end
    end
  end

  describe '#note_invalid_apply' do
    describe 'GET' do
      context '正常処理の場合' do
        it '安否情報登録無効申請画面を描画すること' do
          get :note_invalid_apply, :id => @person.id
          response.should be_success
          response.should render_template(:note_invalid_apply)
        end
      end
      context 'パラメータが不正の場合' do
        it '404のエラー画面が描画されること' do
          get :note_invalid_apply, :id => 1
          response.should be_success
          response.should render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

    end
    describe 'POST' do
      before do
        LgdpfMailer.stub_chain(:send_note_invalid_apply, :deliver)
      end
      context '正常処理の場合' do
        it '設定変更完了画面へ遷移すること' do
          post :note_invalid_apply,
            :id => @person.id,
            :commit => "OK"
          response.should be_redirect
          response.should redirect_to :action => :complete,
            :id => @person.id,
            :complete => {:key => "note_invalid_apply"}
        end
      end
      context 'パラメータが不正の場合' do
        it '404のエラー画面が描画されること' do
          post :note_invalid_apply,
            :id => 1,
            :commit => "OK"
          response.should be_success
          response.should render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

    end

  end

  describe '#note_invalid' do
    describe 'GET' do
      context '正常処理の場合' do
        it '安否情報登録無効画面を描画すること' do
          get :note_invalid, :id => @person.id
          response.should be_success
          response.should render_template(:note_invalid)
        end
      end
      context 'パラメータが不正の場合' do
        it '404のエラー画面が描画されること' do
          get :note_invalid, :id => 1
          response.should be_success
          response.should render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

    end
    describe 'POST' do
      before do
        LgdpfMailer.stub_chain(:send_note_invalid, :deliver)
      end
      context '正常処理の場合' do
        it '人物情報登録確認画面へ遷移すること' do
          post :note_invalid,
            :id => @person.id,
            :commit => "OK"
          response.should be_redirect
          response.should redirect_to :action => :view,
            :id => @person.id
        end
      end
      context 'パラメータが不正の場合' do
        it '404のエラー画面が描画されること' do
          post :note_invalid,
            :id => 1,
            :commit => "OK"
          response.should be_success
          response.should render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

    end
  end

  describe '#note_valid_apply' do
    describe 'GET' do
      context '正常処理の場合' do
        it '安否情報登録有効申請画面を描画すること' do
          get :note_valid_apply, :id => @person.id
          response.should be_success
          response.should render_template(:note_valid_apply)
        end
      end
      context 'パラメータが不正の場合' do
        it '404のエラー画面が描画されること' do
          get :note_valid_apply, :id => 1
          response.should be_success
          response.should render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

    end
    describe 'POST' do
      before do
        LgdpfMailer.stub_chain(:send_note_valid_apply, :deliver)
      end
      context '正常処理の場合' do
        it '設定変更完了画面へ遷移すること' do
          post :note_valid_apply,
            :id => @person.id,
            :commit => "OK"
          response.should be_redirect
          response.should redirect_to :action => :complete,
            :id => @person.id,
            :complete => {:key => "note_valid_apply"}
        end
      end
      context 'パラメータが不正の場合' do
        it '404のエラー画面が描画されること' do
          post :note_valid_apply,
            :id => 1,
            :commit => "OK"
          response.should be_success
          response.should render_template(:file => "#{Rails.root}/public/404.html")
        end
      end

    end
  end

  describe '#note_valid' do
    before do
      LgdpfMailer.stub_chain(:send_note_valid, :deliver)
    end
    describe 'GET' do
      it '人物情報登録確認画面へ遷移すること' do
        get :note_valid, :id => @person.id

        response.should be_redirect
        response.should redirect_to(:action => :view, :id => @person.id)
      end
    end
  end

  describe '#spam' do
    before do
      @note = FactoryGirl.create(:note)
    end
    describe 'GET' do
      it 'スパム報告画面を描画すること' do
        get :spam, :id => @person.id, :note_id => @note.id

        assigns[:person].should be_present
        assigns[:note].should be_present
        response.should be_success
        response.should render_template(:spam)
      end
    end
    describe 'POST' do
      it '人物情報登録確認画面を描画すること' do
        post :spam, :id => @person.id, :note_id => @note.id, :commit => "OK"

        assigns[:person].should be_present
        assigns[:note].should be_present
        response.should be_redirect
        response.should redirect_to :action => :view, :id => @person.id
      end
    end
  end

  describe '#spam_cancel' do
    before do
      @note = FactoryGirl.create(:note)
    end
    describe 'GET' do
      it 'スパム報告取消画面を描画すること' do
        get :spam_cancel, :id => @person.id, :note_id => @note.id

        assigns[:person].should be_present
        assigns[:note].should be_present
        response.should be_success
        response.should render_template(:spam_cancel)
      end
    end
    describe 'POST' do
      it '人物情報登録確認画面を描画すること' do
        post :spam_cancel, :id => @person.id, :note_id => @note.id, :commit => "OK"

        assigns[:person].should be_present
        assigns[:note].should be_present
        response.should be_redirect
        response.should redirect_to :action => :view, :id => @person.id
      end

    end
  end

  describe '#personal_info' do
    describe 'GET' do
      context '人物情報登録確認画面から遷移してきた場合' do
        before do
          session[:action] = "view"
        end
        it '個人情報表示許可画面を描画すること' do
          get :personal_info, :id => @person.id
          session[:action].should == "view"
          response.should be_success
          response.should render_template(:personal_info)
        end
      end
      context '避難者情報重複確認画面から遷移してきた場合' do
        before do
          session[:action] = "multiviews"
          @person2 = FactoryGirl.create(:person)
        end
        it '個人情報表示許可画面を描画すること' do
          get :personal_info, :id => @person.id, :id2 => @person2.id
          session[:action].should == "multiviews"
          response.should be_success
          response.should render_template(:personal_info)
        end
      end
      context 'スパム報告画面から遷移してきた場合' do
        before do
          session[:action] = "spam"
          @note = FactoryGirl.create(:note)
        end
        it '個人情報表示許可画面を描画すること' do
          get :personal_info, :id => @person.id, :note_id => @note.id
          session[:action].should == "spam"
          response.should be_success
          response.should render_template(:personal_info)
        end
      end
      context 'スパム報告取消画面から遷移してきた場合' do
        before do
          session[:action] = "spam_cancel"
          @note = FactoryGirl.create(:note)
        end
        it '個人情報表示許可画面を描画すること' do
          get :personal_info, :id => @person.id, :note_id => @note.id
          session[:action].should == "spam_cancel"
          response.should be_success
          response.should render_template(:personal_info)
        end
      end
    end

    describe 'POST' do
      context '人物情報登録確認画面から遷移してきた場合' do
        before do
          session[:action] = "view"
        end
        it '人物情報登録確認画面へ遷移すること' do
          post :personal_info, :id => @person.id, :commit => "OK"
          session[:action].should == "view"
          response.should be_redirect
          response.should redirect_to(:action => :view, :id => @person.id)
        end
      end
      context '避難者情報重複確認画面から遷移してきた場合' do
        before do
          session[:action] = "multiviews"
          @person2 = FactoryGirl.create(:person)
        end
        it '避難者情報重複確認画面へ遷移すること' do
          post :personal_info, :id => @person.id, :commit => "OK", :id2 => @person2.id
          session[:action].should == "multiviews"
          response.should be_redirect
          response.should redirect_to(:action => :multiviews, :id => @person.id,
            :id1 => @person.id, :id2 => @person2.id)

        end
      end
      context 'スパム報告画面から遷移してきた場合' do
        before do
          @note = FactoryGirl.create(:note)
          session[:action] = "spam"
        end
        it 'スパム報告画面へ遷移すること' do
          post :personal_info, :id => @person.id,
            :note_id => @note.id, :commit => "OK"
          session[:action].should == "spam"
          response.should be_redirect
          response.should redirect_to(:action => :spam, :id => @person.id,
            :note_id => @note.id)
        end
      end
      context 'スパム報告取消画面から遷移してきた場合' do
        before do
          @note = FactoryGirl.create(:note)
          session[:action] = "spam_cancel"
        end
        it 'スパム報告取消画面へ遷移すること' do
          post :personal_info, :id => @person.id,
            :note_id => @note.id, :commit => "OK"
          session[:action].should == "spam_cancel"
          response.should be_redirect
          response.should redirect_to(:action => :spam_cancel, :id => @person.id,
            :note_id => @note.id)
        end
      end
    end

  end

  describe '#complete' do
    describe 'GET' do
      context '避難者情報保持期間延長画面から遷移してきた場合' do
        it '設定変更完了画面を描画すること' do
          get :complete, :id => @person, :complete => {:key => "extend_days"}
          response.should be_success
          response.should render_template(:complete)
        end
      end
      context '新着情報受信許可画面から遷移してきた場合' do
        it '設定変更完了画面を描画すること' do
          get :complete, :id => @person, :complete => {:key => "subscribe_email"}
          response.should be_success
          response.should render_template(:complete)
        end
      end
      context 'メールの新着情報受信停止リンクから遷移してきた場合' do
        it '設定変更完了画面を描画すること' do
          get :complete, :id => @person, :complete => {:key => "unsubscribe_email"}
          response.should be_success
          response.should render_template(:complete)
        end
      end
      context '避難者情報削除画面から遷移してきた場合' do
        it '設定変更完了画面を描画すること' do
          get :complete, :id => @person, :complete => {:key => "delete"}
          response.should be_success
          response.should render_template(:complete)
        end
      end
      context '安否情報無効申請画面から遷移してきた場合' do
        it '設定変更完了画面を描画すること' do
          get :complete, :id => @person, :complete => {:key => "note_invalid_apply"}
          response.should be_success
          response.should render_template(:complete)
        end
      end
      context '安否情報有効申請画面から遷移してきた場合' do
        it '設定変更完了画面を描画すること' do
          get :complete, :id => @person, :complete => {:key => "note_valid_apply"}
          response.should be_success
          response.should render_template(:complete)
        end
      end

    end
  end

end






