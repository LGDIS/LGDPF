# -*- coding:utf-8 -*-
class PeopleController < ApplicationController

  before_filter :init
  
  def init
    @person_const = get_const Person.table_name
    @note_const   = get_const Note.table_name
  end

  def index

  end

  def seek
    if params[:first_step]
      if params[:name].present?
        @person = Person.find_for_seek(params)
      else
        flash.now[:error] = "その人の名前、または名前の一部を入力してください。 "
      end
    end
  end

  def provide
    if params[:first_step]
      if params[:family_name].present? && params[:given_name].present?
        @person = Person.find_for_provide(params)
        if @person.present?
          render :action => "provide"
        else
          redirect_to :action => "new",
            :family_name => params[:family_name],
            :given_name  => params[:given_name]
        end
      else
        flash.now[:error] = "その人の姓名を入力してください。  "
        render :action => "provide"
      end
    end
  end

  def multiviews
    @person = Person.find_by_id(1)
    @person2 = Person.find_by_id(2)
    @person3 = Person.find_by_id(3)
  end


  def new
    p "****** new ************************"
    @person = Person.new
    @person.family_name = params[:family_name]
    @person.given_name = params[:given_name]
    @note = Note.new
    @kana = {:family_name => "", :given_name => ""}
    @subscribe = ""

    # 遷移元確認フラグ
    if params[:family_name].blank? && params[:given_name].blank?
      @from_seek = true
    end
  end

  def create
    p "****** create ************************"
    # Person, Noteの登録
    Person.transaction do
      # 遷移元確認フラグ
      if params[:note].blank?
        @from_seek = true
      end

      @person = Person.new(params[:person])
      @person[:expiry_date] = Time.now.advance(:days => params[:person][:expiry_date].to_i)

      # 読み仮名登録用
      unless params[:kana].blank?
        @person[:alternate_names] = params[:kana][:family_name] + " " + params[:kana][:given_name]
      end
      # 読み仮名画面再表示用
      @kana = params[:kana]
      @subscribe = params[:subscribe].present? ? true : ""

      if params[:note].present?
        @note = Note.new(params[:note])
        @note[:last_known_location]  = params[:clickable_map][:location_field]
        @note[:note_author_made_contact] = params[:note][:note_author_made_contact_yes] ? true : false
        @note[:author_name]  = @person.author_name unless params[:note][:author_name].present?
        @note[:author_email] = @person.author_email unless params[:note][:author_email].present?
        @note[:author_phone] = @person.author_phone unless params[:note][:author_phone].present?
        @note[:source_date]  = @person.source_date unless params[:note][:source_date].present?
      end
      
      @person.save!

      if params[:note].present?
        @note[:person_record_id] = @person.id
        @note.save!
      end
    end
    redirect_to :action => "view", :id => @person.id
  rescue
    if @note.errors.messages[:author_made_contact].present?
      flash.now[:error] = @note.errors.messages[:author_made_contact][0]
    else
      flash.now[:error] = "すべての必須フィールドに入力してください。 "
    end
    render :action => "new"
  end

  def view
    @person = Person.find(params[:id])
    @notes = Note.find(:all,
      :conditions => ["person_record_id = ?", @person.id])
    @note = Note.new
    session[:action] = action_name
  end

  def update
    @person = Person.find(params[:id])

    if params[:extend_days].present?
      redirect_to :action => "extend_days", :id => @person
      return
    elsif params[:subscribe_email].present?
      redirect_to :action => "subscribe_email", :id => @person
      return
    elsif params[:delete].present?
      redirect_to :action => "delete", :id => @person
      return
    elsif params[:note_invalid_apply].present?
      redirect_to :action => "note_invalid_apply", :id => @person
      return
    elsif params[:note_valid_apply].present?
      redirect_to :action => "note_valid_apply", :id => @person
      return
    end
    
    @note = Note.new(params[:note])
    @note.person_record_id     = @person.id
    @note.last_known_location  = params[:clickable_map][:location_field]
    if @note.save
      session[:pi_view] = false  # 個人情報表示を無効にする
      redirect_to :action => :view, :id => @person
    else
      flash.now[:error] = "すべての必須フィールドに入力してください。 "
      render :action => "view"
    end
  end

  # 避難者情報保持期間延長画面
  def extend_days
    @person = Person.find(params[:id])
  end

  # 新着情報受信許可画面
  def subscribe_email
    @person = Person.find(params[:id])
  end

  # 避難者情報削除画面
  def delete
    @person = Person.find(params[:id])
  end

  # 安否情報登録無効申請画面
  def note_invalid_apply
    @person = Person.find(params[:id])
  end

  # 安否情報登録有効申請画面
  def note_valid_apply
    @person = Person.find(params[:id])
  end

  # スパム報告画面
  def spam
    @person = Person.find(params[:id])
    @note = Note.find(params[:note_id])
    session[:action] = action_name
    if params[:commit].present?
      @note.spam_flag = true  # 認定:true, 取消:false
      if @note.save!
        redirect_to :action => :view, :id => @person
      end
    end
  end

  # スパム報告取消画面
  def spam_cancel
    @person = Person.find(params[:id])
    @note = Note.find(params[:note_id])
    session[:action] = action_name
    if params[:commit].present?
      @note.spam_flag = false  # 認定:true, 取消:false
      if verify_recaptcha(:model => @user, :message => 'reCAPTCHA error.') && @note.save!
        redirect_to :action => :view, :id => @person
      end
    end
  end

  # 削除データ復元画面
  def restore
    @person = Person.find(params[:id])
    session[:action] = action_name
    if params[:commit].present?
      # @note.spam_flag = false  # 認定:true, 取消:false
      # if @note.save!
      redirect_to :action => :view, :id => @person
      # end
    end
  end

  # 個人情報表示許可画面
  def personal_info
    @person = Person.find(params[:id])
    @note = Note.find(params[:note_id])
    if params[:commit].present?
      session[:pi_view] = true
      if session[:action] == "spam"
        redirect_to :action => session[:action], :id => @person, :note_id => @note
      else
        redirect_to :action => session[:action], :id => @person
      end
    end

  end


  # 完了画面
  def complete
    @person = Person.find(params[:id])
    @key = params[:complete][:key]
  end



  
end
