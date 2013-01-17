# -*- coding:utf-8 -*-
class PeopleController < ApplicationController

  before_filter :init

  # コンスタントマスタの読み込み
  def init
    @person_const = get_const Person.table_name
    @note_const   = get_const Note.table_name
  end

  # トップ画面
  def index

  end

  # 避難者を検索する
  def seek
    if params[:first_step]
      if params[:name].present?
        @person = Person.find_for_seek(params)
      else
        flash.now[:error] = "その人の名前、または名前の一部を入力してください。 "
      end
    end
  end

  # 情報提供する避難者情報が既に登録されているか確認する
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

  # 避難者情報重複確認画面
  def multiviews
    @count = params[:mark_count].to_i + 1
    @person = Person.find_by_id(params[:id1])
    @person2 = Person.find_by_id(params[:id2])
    @person3 = Person.find_by_id(params[:id3]) unless params[:id3].blank?
    @note = Note.new
  end

  # 重複した避難者をまとめる
  def dup_merge
    # エラー時に入力値を保持する
    @count = params[:count].to_i
    @person = Person.find_by_id(params[:person][:id])
    @person2 = Person.find_by_id(params[:person2][:id])
    @person3 = Person.find_by_id(params[:person3][:id]) unless params[:id3].blank?
    #
    @note = Note.new(params[:note])
    @note.person_record_id  =  params[:person][:id]
    @note.linked_person_record_id  =  params[:person2][:id]
    @note.linked_person_record_id  =  params[:person3][:id] if params[:person3][:id].present?
    @note2 = Note.new(params[:note])
    @note2.person_record_id  =  params[:person2][:id]
    @note2.linked_person_record_id  =  params[:person][:id]
    @note2.linked_person_record_id  =  params[:person3][:id] if params[:person3][:id].present?
    if params[:person3][:id].present?
      @note3 = Note.new(params[:note])
      @note3.person_record_id  =  params[:person3][:id]
      @note3.linked_person_record_id =  params[:person][:id]
      @note3.linked_person_record_id =  params[:person2][:id]
    end
    Note.transaction do
      @note.save!
      @note2.save!
      @note3.save! unless params[:person3][:id].blank?
    end
    session[:pi_view] = false  # 個人情報表示を無効にする
    redirect_to :action => :view, :id =>  params[:person][:id]
  rescue
    flash.now[:error] = "すべての必須フィールドに入力してください。 "
    render :action => "multiviews"
  end

  # 新規作成画面
  def new
    @person = Person.new
    @person.family_name = params[:family_name]
    @person.given_name = params[:given_name]
    @note = Note.new
    @kana = {:family_name => "", :given_name => ""}

    # 遷移元確認フラグ
    if params[:family_name].blank? && params[:given_name].blank?
      @from_seek = true
    end
  end

  # 新規情報登録
  def create
    # Person, Noteの登録
    Person.transaction do
      # 遷移元確認フラグ
      if params[:note].blank?
        @from_seek = true
      end

      # 画面入力値を加工
      @person = Person.set_values(params[:person])

      # 読み仮名登録用
      unless params[:kana].blank?
        @person[:alternate_names] = params[:kana][:family_name] + " " + params[:kana][:given_name]
      end
      # 読み仮名画面再表示用
      @kana = params[:kana]

      # provideから遷移してきた場合
      if params[:note].present?
        @note = Note.new(params[:note])
        @note[:last_known_location]  = params[:clickable_map][:location_field]
        @note[:note_author_made_contact] = params[:note][:note_author_made_contact_yes] ? true : false
        # Noteの投稿者情報を入力する
        @note[:author_name]  = @person.author_name if params[:note][:author_name].blank?
        @note[:author_email] = @person.author_email if params[:note][:author_email].blank?
        @note[:author_phone] = @person.author_phone if params[:note][:author_phone].blank?
        @note[:source_date]  = @person.source_date if params[:note][:source_date].blank?
      end
      
      @person.save!

      if params[:note].present?
        @note[:person_record_id] = @person.id
        @note.save!
      end
    end

    if @person.email_flag
      redirect_to :action => "subscribe_email", :id => @person.id
    else
      redirect_to :action => "view", :id => @person.id
    end
  rescue
    if @note.present? && @note.errors.messages[:author_made_contact].present?
      flash.now[:error] = @note.errors.messages[:author_made_contact][0]
    else
      flash.now[:error] = "すべての必須フィールドに入力してください。 "
    end
    render :action => "new"
  end

  # 詳細画面
  def view
    @person = Person.find(params[:id])
    # 論理削除されている場合
    unless @person.deleted_at.blank?
      flash.now[:error] = "この人の記録は存在しないか、削除されました。"
    end

    @note = Note.new
    session[:action] = action_name
    
    @dup_flag = Person.check_dup(params[:id])  # 重複の有無
    @dup_people = Person.duplication(params[:id]) # personと重複するperson

    # 重複メモを表示するか
    if params[:duplication].present?
      @notes = Note.find_all_by_person_record_id(@person.id)
    else
      @notes = Note.no_duplication(@person.id)
    end
  end

  # 安否情報を追加する
  def update
    @person = Person.find(params[:id])

    # 登録以外のボタンを押されたら別画面に遷移する
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
    @note.email_flag = params[:note][:email_flag] == "true" ? true : false
    @note.person_record_id     = @person.id
    @note.last_known_location  = params[:clickable_map][:location_field]
    if @note.save
      if @note.email_flag
        redirect_to :action => "subscribe_email", :id => @person.id
      else
        session[:pi_view] = false  # 個人情報表示を無効にする
        LgdpfMailer.send_new_information(@person).deliver
        redirect_to :action => :view, :id => @person
      end
    else
      flash.now[:error] = "すべての必須フィールドに入力してください。 "
      render :action => "view"
    end
  end

  # 避難者情報保持期間延長画面
  def extend_days
    @person = Person.find(params[:id])
    if params[:commit].present?
      @person.expiry_date = @person.expiry_date + 60.days
      if verify_recaptcha && @person.save!
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "extend_days"}
      end
    end
  end

  # 新着情報受信許可画面
  def subscribe_email
    @person = Person.find(params[:id])
    #   @note = Person.find(params[:note_id])
    if params[:commit].present?
      @person.author_email = params[:person][:author_email]
      # author_emailに重複がある場合は受取フラグを消す
      if Note.find_for_author_email(@person)
        @person.email_flag = false
      end
      if verify_recaptcha && @person.save!
        LgdpfMailer.send_new_information(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "subscribe_email"}
      end
    end
  end

  # 新着情報受信拒否
  def unsubscribe_email
    @person = Person.find(params[:id])
    #   @note = Person.find(params[:note_id])
    @person.email_flag = false
    if @person.save!
      redirect_to :action => :complete,
        :id => @person,
        :complete => {:key => "unsubscribe_email"}
    end
  end

  # 避難者情報削除画面
  def delete
    @person = Person.find(params[:id])
    if params[:commit].present?
      if verify_recaptcha && @person.destroy!
        LgdpfMailer.send_delete_notice(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "delete"}
      end
    end
  end

  # 削除データ復元画面
  def restore
    begin
      @person = Person.with_deleted.find(params[:id])
      if params[:commit].present?
        @person.deleted_at = ""
        if verify_recaptcha && @person.save!
          LgdpfMailer.send_restore_notice(@person).deliver
          redirect_to :action => :view, :id => @person
        end
      end
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end
  end

  # 安否情報登録無効申請画面
  def note_invalid_apply
    @person = Person.find(params[:id])
    if params[:commit].present?
      if verify_recaptcha
        LgdpfMailer.send_note_invalid_apply(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "note_invalid_apply"}
      end
    end
  end

  # 安否情報登録無効画面
  def note_invalid
    begin
      @person = Person.find(params[:id])
      if params[:commit].present?
        @person.notes_disabled = true
        if @person.save!
          LgdpfMailer.send_note_invalid(@person).deliver
          redirect_to :action => :view, :id => @person
        end
      end
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end
  end

  # 安否情報登録有効申請画面
  def note_valid_apply
    @person = Person.find(params[:id])
    if params[:commit].present?
      if verify_recaptcha
        LgdpfMailer.send_note_valid_apply(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "note_valid_apply"}
      end
    end
  end

  # 安否情報登録有効画面
  def note_valid
    begin
      @person = Person.find(params[:id])
      @person.notes_disabled = false
      if @person.save!
        LgdpfMailer.send_note_valid(@person).deliver
        redirect_to :action => :view, :id => @person
      end
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end

  end

  # スパム報告画面
  def spam
    begin
      @person = Person.find(params[:id])
      @note = Note.find(params[:note_id])
      session[:action] = action_name
      if params[:commit].present?
        @note.spam_flag = true  # 認定:true, 取消:false
        if @note.save!
          redirect_to :action => :view, :id => @person
        end
      end
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end
  end

  # スパム報告取消画面
  def spam_cancel
    begin
      @person = Person.find(params[:id])
      @note = Note.find(params[:note_id])
      session[:action] = action_name
      if params[:commit].present?
        @note.spam_flag = false  # 認定:true, 取消:false
        if verify_recaptcha && @note.save!
          redirect_to :action => :view, :id => @person
        end
      end
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end
  end

  # 個人情報表示許可画面
  def personal_info
    begin
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
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end
  end


  # 完了画面
  def complete
    begin
      @person = Person.find(params[:id])
      @key = params[:complete][:key]
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end

  end



  
end
