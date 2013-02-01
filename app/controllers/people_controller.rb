# -*- coding:utf-8 -*-
# 利用規約の同意しない場合に発生するエラー
class ConsentError < StandardError; end

class PeopleController < ApplicationController

  before_filter :init, :expiry_date

  # コンスタントマスタの読み込み
  def init
    @person_const = Constant.get_const(Person.table_name)
    @note_const   = Constant.get_const(Note.table_name)
    #    @area = get_cache("area")
    #    @address = Rails.cache.read("address")
    #    @shelter = get_cache("shelter")
  end

  # 有効期限の確認
  def expiry_date
    if params[:token].present?
      aal = ApiActionLog.find_by_unique_key(params[:token])
      if aal.blank? || (aal.entry_date + 3.days) < Time.now
        raise ActiveRecord::RecordNotFound
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :file => "#{Rails.root}/public/404.html"
  end

  # 利用規約画面
  def terms_of_service
    f = open("#{Rails.root}/config/terms_message.txt")
    @terms_message =  f.read
    f.close
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
        flash.now[:error] = "その人の姓名を入力してください。"
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
    @subscribe = false
  end

  # 重複した避難者をまとめる
  def dup_merge
    # エラー時に入力値を保持する
    @count = params[:count].to_i
    @person = Person.find_by_id(params[:person][:id])
    @person2 = Person.find_by_id(params[:person2][:id])
    @person3 = Person.find_by_id(params[:person3][:id]) unless params[:id3].blank?
    @subscribe = params[:subscribe] == "true" ? true : false

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
    # 新着メールを送るアドレスを抽出
    to = Person.subscribe_email_address(@person)

    Note.transaction do
      @note.save!
      @note2.save!
      @note3.save! unless params[:person3][:id].blank?
    end
    # Personに新着メールを送信する
    to.each do |address|
      LgdpfMailer.send_add_note(@person, @note, address).deliver
      LgdpfMailer.send_add_note(@person2, @note, address).deliver
      LgdpfMailer.send_add_note(@person3, @note, address).deliver unless params[:person3][:id].blank?
    end
    if @subscribe
      redirect_to :action => "subscribe_email",
        :id => @person,
        :id2 => @person2,
        :id3 => @person3,
        :note_id => @note,
        :note_id2 => @note2,
        :note_id3 => @note3
    else
      session[:pi_view] = false  # 個人情報表示を無効にする
      redirect_to :action => :view, :id => @person
    end
  rescue ActiveRecord::RecordNotFound
    render :file => "#{Rails.root}/public/404.html"
  rescue
    render :action => "multiviews"
  end

  # 新規作成画面
  def new
    @person = Person.new
    @person.family_name = params[:family_name]
    @person.given_name = params[:given_name]
    @note = Note.new
    @kana = {:family_name => "", :given_name => ""}
    @subscribe = false
    @error_message = "入力したURLの形式が不正です。プロフィールURLをコピーして貼り付けてください。"
    # 遷移元確認フラグ
    if params[:family_name].blank? && params[:given_name].blank?
      @from_seek = true
    end
  end

  # 新規情報登録
  def create
    @error_message = "入力したURLの形式が不正です。プロフィールURLをコピーして貼り付けてください。"
    # Person, Noteの登録
    Person.transaction do
      # 遷移元確認フラグ
      if params[:note].blank?
        @from_seek = true
      end
      # 画面入力値を加工
      @person = Person.set_values(params[:person])
      @consent = params[:consent] == "true" ? true :false
      @subscribe = params[:subscribe]== "true" ? true : false
      @clone_clone_input = params[:clone][:clone_input] == "no" ? true : false
      if @clone_clone_input
        @person[:source_name] = request.headers["host"]
      end
      @person[:profile_urls] = set_profile_urls


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
      
      @person.save

      if params[:note].present?
        @note[:person_record_id] = @person.id
        @note.save!
      end
      if @person.errors.messages.present?
        raise ActiveRecord::RecordNotFound
      end

      # 利用規約のチェック判定
      unless @consent
        raise ConsentError
      end

    end
   
    if @subscribe
      redirect_to :action => "subscribe_email", :id => @person
    else
      redirect_to :action => "view", :id => @person
    end

  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    render :action => "new"
  rescue ConsentError
    flash.now[:error] = "利用規約に同意していただかないと、情報を登録することはできません。"
    render :action => "new"
  end

  # 詳細画面
  def view
    @person = Person.find(params[:id])

    @note = Note.new
    session[:action] = action_name
    
    @dup_flag = Person.check_dup(params[:id])  # 重複の有無
    @dup_people = Person.duplication(params[:id]) # personと重複するperson
    @subscribe = false
    # 重複メモを表示するか
    if params[:duplication].present?
      @notes = Note.where(:person_record_id => @person.id).order("entry_date ASC")
    else
      @notes = Note.no_duplication(@person.id)
    end
  rescue ActiveRecord::RecordNotFound
    render :file => "#{Rails.root}/public/404.html"
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
    @note.person_record_id     = @person.id
    @note.last_known_location  = params[:clickable_map][:location_field]
    @consent = params[:consent] == "true" ? true :false
    @subscribe = params[:subscribe]== "true" ? true : false
    if params[:duplication].present?
      @notes = Note.where(:person_record_id => @person.id).order("entry_date ASC")
    else
      @notes = Note.no_duplication(@person.id)
    end

    # 利用規約のチェック判定
    unless @consent
      raise ConsentError
    end

    # 新着メールを送るアドレスを抽出
    to = Person.subscribe_email_address(@person)

    if @note.save!
      # Personに新着メールを送信する
      to.each do |address|
        LgdpfMailer.send_add_note(@person, @note, address).deliver
      end
     
      # 新規登録したnoteが新着メールを受け取るか
      if @subscribe
        redirect_to :action => "subscribe_email", :id => @person.id, :note_id => @note.id
      else
        session[:pi_view] = false  # 個人情報表示を無効にする
        redirect_to :action => :view, :id => @person
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :file => "#{Rails.root}/public/404.html"
  rescue ConsentError
    flash.now[:error] = "利用規約に同意していただかないと、情報を登録することはできません。"
    render :action => "view"
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
    @person = Person.find(params[:id])  # ウォッチする避難者
    @person2 = Person.find(params[:id2]) if params[:id2].present? # ウォッチする避難者
    @person3 = Person.find(params[:id3]) if params[:id3].present? # ウォッチする避難者
    @note = Note.find_by_id(params[:note_id]) if params[:note_id].present?
    @note2 = Note.find_by_id(params[:note_id2]) if params[:note_id2].present?
    @note3 = Note.find_by_id(params[:note_id3]) if params[:note_id3].present?

    if params[:commit].present?
      if params[:note].blank?  # personで新着受取チェック
        if params[:person][:author_email].blank?
          flash.now[:error] = "メールアドレスに問題があります。再度入力してください。"
        end
        @person.email_flag = true
        @person.author_email = params[:person][:author_email]
        # author_emailに重複がある場合は受取フラグを消す
        if Note.check_for_author_email(@person)
          @person.email_flag = false
        end
        @person.save!
      else  # noteで新着受取チェック
        if params[:note][:author_email].blank?
          flash.now[:error] = "メールアドレスに問題があります。再度入力してください。"
        end
        Note.transaction do
          @note.author_email = params[:note][:author_email]
          @note.email_flag = true
          @note.email_flag  = false if Note.check_for_author_email(@person)
          @note.save!
          if @note2.present?
            @note2.author_email = params[:note][:author_email]
            @note2.email_flag = true
            @note2.email_flag = false if Note.check_for_author_email(@person2)
            @note2.save!
          end
          if @note3.present?
            @note3.author_email = params[:note][:author_email]
            @note3.email_flag = true
            @note3.email_flag = false if Note.check_for_author_email(@person3)
            @note3.save!
          end
        end
      end
      if verify_recaptcha
        if @note.blank?
          LgdpfMailer.send_new_information(@person, nil).deliver
        else
          LgdpfMailer.send_new_information(@person, @note).deliver
          LgdpfMailer.send_new_information(@person2, @note2).deliver if @note2.present?
          LgdpfMailer.send_new_information(@person3, @note3).deliver if @note3.present?
        end
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "subscribe_email"}
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :file => "#{Rails.root}/public/404.html"
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
      @person.destroy
      if verify_recaptcha
        LgdpfMailer.send_delete_notice(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "delete"}
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :file => "#{Rails.root}/public/404.html"
  end

  # 削除データ復元画面
  def restore
    begin
      @person = Person.with_deleted.find(params[:id])
      if @person.deleted_at.blank?  # 復元されている場合
        redirect_to :action => :view, :id => @person
      end
      if params[:commit].present?
        @person.recover
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
      @note = Note.find(params[:note_id]) unless params[:note_id].blank?
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
    @key = params[:complete][:key]
    begin
      if @key == "delete"
        @person = Person.with_deleted.find(params[:id])
      else
        @person = Person.find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      render :file => "#{Rails.root}/public/404.html"
    end

  end

  private
  def set_profile_urls
    urls = [params[:profile_url1], params[:profile_url2], params[:profile_url3]]
    urls.delete("")
    return urls.join("\n")
  end



  
end
