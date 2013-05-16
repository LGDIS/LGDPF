# -*- coding:utf-8 -*-
require "net/smtp"

# 利用規約の同意しない場合に発生するエラー
class ConsentError < StandardError; end
# 新着情報受取画面でメールアドレスの入力が空の場合に発生するエラー
class EmailBlankError < StandardError; end

class PeopleController < ApplicationController

  include PersonHelper
  include Jpmobile::ViewSelector # モバイル時のView自動振り分け
  layout :layout_selector

  # レイアウトの選択処理
  # 各画面で使用するレイアウトを決定する
  # ==== Args
  # _action_ :: 画面識別子
  # ==== Return
  # レイアウト名
  # ==== Raise
  def layout_selector
    case params[:action]
    when "index", "new", "person_create", "complete", "view", "seek", "search_results",
         "note_list", "note_new", "update_note_preview", "update_note", "note_preview"
      request.mobile? ? 'mobile' : 'application'
    else
      'application'
    end
  end

  # トップ画面
  # === Args
  # === Return
  # === Raise
  def index

  end

  # 検索画面
  # === Args
  # _name_ :: 画面入力された検索条件
  # _role_ :: 画面種別
  # === Return
  # === Raise
  def seek
    # 検索条件を保持
    @query = params[:name]
    @query_family = ""
    @query_given  = ""
    @action = action_name
    if params[:role]
      if params[:name].present?
        @person = Person.find_for_seek(params)
      else
        flash.now[:error] = I18n.t("activerecord.errors.messages.seek_blank")
      end
    end
  end

  # 検索結果(モバイル)
  # === Args
  # _name_ :: 画面入力された検索条件
  # _role_ :: 画面種別
  # === Return
  # === Raise
  def search_results
    # 検索条件を保持
    @query = params[:name]
    @query_family = ""
    @query_given  = ""
    @action = action_name
    if params[:role]
      if params[:name].present?
        @person = Kaminari.paginate_array(Person.find_for_seek(params)).page(params[:page]).per(10)
      else
        flash.now[:error] = I18n.t("activerecord.errors.messages.seek_blank")
      end
    end
  end

  # 安否情報対象者入力画面
  # === Args
  # _family_name_ :: 画面入力された検索条件(姓)
  # _given_name_  :: 画面入力された検索条件(名)
  # _role_ :: 画面種別
  # === Return
  # === Raise
  def provide
    # 検索条件を保持
    @query = ""
    @query_family = params[:family_name]
    @query_given  = params[:given_name]
    @action = action_name
    if params[:role]
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
        flash.now[:error] = I18n.t("activerecord.errors.messages.provide_blank")
        render :action => "provide"
      end
    end
  end


  # 避難者情報重複確認画面
  # === Args
  # _id1_ :: 検索一覧で選択されたPerson.id
  # _id2_ :: 検索一覧で選択されたPerson.id
  # _id3_ :: 検索一覧で選択されたPerson.id
  # === Return
  # === Raise
  def multiviews
    @count = params[:id3].blank? ? 3 : 4  # 重複件数が2件 or 3件
    @person = Person.find_by_id(params[:id1])
    @person2 = Person.find_by_id(params[:id2])
    @person3 = Person.find_by_id(params[:id3]) unless params[:id3].blank?
    @note = Note.new
    @subscribe = false
    session[:action] = action_name
  end

  # 重複安否情報登録のプレビュー画面
  # === Args
  # === Return
  # === Raise
  def duplication_preview
    # エラー時に入力値を保持する
    @count = params[:count].to_i
    @person = Person.find_by_id(params[:person][:id])
    @person2 = Person.find_by_id(params[:person2][:id])
    @person3 = Person.find_by_id(params[:person3][:id]) if params[:person3][:id].present?
    @subscribe = params[:subscribe] == "true" ? true : false
    @consent = params[:consent] == "true" ? true :false

    @note = Note.new(params[:note])
    # 入力値チェック
    @note.invalid?

    if @note.errors.messages.present?
      raise ActiveRecord::RecordInvalid.new(@note)
    end

  rescue ActiveRecord::RecordInvalid
    render :action => "multiviews"
  end


  # 重複した避難者をまとめる
  # === Args
  # _person_    :: Person
  # _note_      :: Note
  # _count_     :: 重複件数
  # _subscribe_ :: 新着情報受信のチェック有無
  # _consent_   :: 利用規約に同意するのチェック有無
  # === Return
  # === Raise
  def dup_merge
    # エラー時に入力値を保持する
    @count = params[:count].to_i
    @person = Person.find_by_id(params[:person][:id])
    @person2 = Person.find_by_id(params[:person2][:id])
    @person3 = Person.find_by_id(params[:person3][:id]) if params[:person3][:id].present?
    @subscribe = params[:subscribe] == "true" ? true : false
    @consent = params[:consent] == "true" ? true :false
    @note = Note.new(params[:note])  # saveしてはいけない(再表示用)

    # 重複可能性のあるperson_record_id
    save_format = []
    if params[:person3][:id].present?
      dup_ids = [@person.id, @person2.id, @person3.id]
    else
      dup_ids = [@person.id, @person2.id]
    end

    # 新着情報
    session[:person_id] = dup_ids

    # [親id, [重複id1(,重複id2)]]を作成する
    dup_ids.each_with_index do |id, i|
      tmp = dup_ids.dup
      save_format << [tmp.delete_at(i), tmp]
    end

    # 重複Noteの登録
    session[:note_id] = []
    Note.transaction do
      save_format.each do |row|
        # 紐付くNoteを作成
        note = Note.new(params[:note])
        note.person_record_id = row[0]
        row[1].each do |dup_id|
          # 重複idを設定
          note_cp = note.dup
          note_cp.linked_person_record_id = dup_id
          note_cp.save!
          session[:note_id] << note_cp.id
        end
      end
    end

    # 利用規約のチェック判定
    unless @consent
      raise ConsentError
    end

    # 重複するPerson全てにメールを送信する
    session[:person_id].each do |person_id|
      person = Person.find_by_id(person_id)
      # 新着メールを送るアドレスを抽出
      to = Person.subscribe_email_address(person, Note.find_by_id(session[:note_id].first))
      # Personに新着メールを送信する
      to.each do |address|
        LgdpfMailer.send_add_note(address).deliver
      end
    end

    if @subscribe
      redirect_to :action => :subscribe_email
    else
      redirect_to :action => :view, :id => @person
    end
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :duplication_preview
  rescue ConsentError
    flash.now[:error] = I18n.t("activerecord.errors.messages.disagree")
    render :action => :duplication_preview
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    render :action => :duplication_preview
  end

  # 新規作成画面
  # === Args
  # _family_name_ :: 安否情報対象者入力画面で入力した値
  # _given_name_  :: 安否情報対象者入力画面で入力した値
  # === Return
  # === Raise
  def new
    @person = Person.new
    @person.family_name = params[:family_name]
    @person.given_name = params[:given_name]
    @note = Note.new
    @kana = {:family_name => "", :given_name => ""}
    @subscribe = false
    @clone_clone_input = true
    @error_message =  I18n.t("activerecord.errors.messages.profile_invalid")
    # 遷移元確認フラグ
    if params[:family_name].blank? && params[:given_name].blank?
      @from_seek = true
    end
    session[:action] = action_name
  end

  # 新規登録のプレビュー画面
  # === Args
  # _person_    :: Person
  # _note_      :: Note
  # _subscribe_ :: 新着情報受信のチェック有無
  # _clone_     :: 新規か複製か
  # _kana_      :: よみがな
  # _clickable_map_ :: 最後に見かけた場所
  # === Return
  # === Raise
  def new_preview

    # 遷移元確認フラグ
    if params[:note].blank?
      @from_seek = true
    end
    @kana = params[:kana]
    @clone_clone_input = (params[:clone][:clone_input] == "no" ? true : false)
    @subscribe = (params[:subscribe] == "true" ? true : false)
    @error_message = I18n.t("activerecord.errors.messages.profile_invalid")

    @person = Person.new(params[:person])

    # 入力値をDBに格納できる形式に加工する
    # Person
    # よみがな
    unless params[:kana].blank?
      @person.alternate_names = params[:kana][:family_name] + " " + params[:kana][:given_name]
    end
    # プロフィール
    @person.profile_urls = set_profile_urls
    # 削除予定日時
    @person.expiry_date = Time.now.advance(:days => params[:person][:expiry_date].to_i)
    # 情報元のサイト名
    if @clone_clone_input
      @person.source_name = `hostname`
    end
    # 情報元の投稿日の入力が日付までの場合datetime型に変換する
    if @person.source_date_before_type_cast =~ /^(\d{4})(?:\/|-|.)?(\d{1,2})(?:\/|-|.)?(\d{1,2})$/
      datetime_str = @person.source_date.strftime("%Y/%m/%d %H:%M:%S %Z")
      @person.source_date = Time.parse(datetime_str)
    end
    # 入力値チェック
    @person.invalid?

    # 写真の実体を一時的に保管しているパスを格納する
    session[:photo_person] = @person.photo_url

    # Note
    if params[:note].present?
      @note = Note.new(params[:note])
      @note.last_known_location  = params[:clickable_map][:location_field]
      # Noteの投稿者情報を入力する
      @note.author_name  = @person.author_name
      @note.author_email = @person.author_email
      @note.author_phone = @person.author_phone
      @note.source_date  = @person.source_date
      # 入力値チェック
      @note.invalid?

      # 写真の実体を一時的に保管しているパスを格納する
      session[:photo_note]   = @note.photo_url
    end

    if @person.errors.messages.present?
      raise ActiveRecord::RecordInvalid.new(@person)
    elsif @note && @note.errors.messages.present?
      raise ActiveRecord::RecordInvalid.new(@note)
    end

  rescue ActiveRecord::RecordInvalid
    render :action => "new"
  end

  # 新規登録処理（モバイル）
  # === Args
  # _person_    :: Person
  # _note_      :: Note
  # _subscribe_ :: 新着情報受信のチェック有無
  # _clone_     :: 新規か複製か
  # _kana_      :: よみがな
  # _clickable_map_ :: 最後に見かけた場所
  # === Return
  # === Raise
  def person_create
    @person = Person.new(params[:person])

    @kana = params[:kana]
    @clone_clone_input = (params[:clone][:clone_input] == "no" ? true : false)
    @subscribe = (params[:subscribe] == "true" ? true : false)
    @error_message = I18n.t("activerecord.errors.messages.profile_invalid")

    # 入力値をDBに格納できる形式に加工する
    # Person
    # よみがな
    unless params[:kana].blank?
      @person.alternate_names = params[:kana][:family_name] + " " + params[:kana][:given_name]
    end
    # プロフィール
    @person.profile_urls = set_profile_urls
    # 削除予定日時
    time = Time.now.advance(:days => params[:person][:expiry_date].to_i)
    @person.expiry_date = Time.parse(time.to_s(:db))
    # 情報元のサイト名
    if @clone_clone_input
      @person.source_name = `hostname`
    end
    # 情報元の投稿日の入力が日付までの場合datetime型に変換する
    if @person.source_date_before_type_cast =~ /^(\d{4})(?:\/|-|.)?(\d{1,2})(?:\/|-|.)?(\d{1,2})$/
      datetime_str = @person.source_date.strftime("%Y/%m/%d %H:%M:%S %Z")
      @person.source_date = Time.parse(datetime_str)
    end
    # 入力値チェック
    @person.invalid?

    # 写真の実体を一時的に保管しているパスを格納する
    session[:photo_person] = @person.photo_url

    if @person.errors.messages.present?
      raise ActiveRecord::RecordInvalid.new(@person)
    end

    # 新着情報受信時メールアドレスが空でないことをチェック
    if @subscribe && params[:person][:author_email].blank?
      raise EmailBlankError
    end

    # Person, Noteの登録
    Person.transaction do
      # Personの登録
      @person.photo_url = session[:photo_person]

      # 入力値をDBに格納できる形式に加工する
      # Person
      # よみがな
      if params[:kana].present?
        @person.alternate_names = params[:kana][:family_name] + " " + params[:kana][:given_name]
      end

      @person.save

      # 新規情報の場合
      if @clone_clone_input
        @person.source_url = url_for(:action => :view, :id => @person.id, :only_path => false)
        @person.save
      end

      # Noteの登録
      if params[:note].present?
        @note = Note.new(params[:note])
        @note.person_record_id = @person.id
        @note.photo_url = session[:photo_note]
        @note.save!
      end

    end

    if @subscribe
      session[:person_id] = [@person.id]
      session[:note_id]   = [@note.try(:id)]
      subscribe_email_person
    else
      redirect_to :action => "view", :id => @person
    end

  rescue ActiveRecord::RecordInvalid
    render "new"
  rescue EmailBlankError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_blank")
    render "new"
  end

  # 新規情報登録
  # === Args
  # _person_    :: Person
  # _note_      :: Note
  # _subscribe_ :: 新着情報受信のチェック有無
  # _consent_   :: 利用規約に同意するのチェック有無
  # _clone_     :: 新規か複製か
  # _kana_      :: よみがな
  # _clickable_map_ :: 最後に見かけた場所
  # === Return
  # === Raise
  def create

    # 遷移元確認フラグ
    if params[:note].blank?
      @from_seek = true
    end
    @kana      = params[:kana]
    @clone_clone_input = params[:clone][:clone_input] == "no" ? true : false
    @subscribe = params[:subscribe] == "true" ? true : false
    @consent   = params[:consent]   == "true" ? true : false

    # Person, Noteの登録
    Person.transaction do
      # Personの登録
      @person = Person.new(params[:person])
      @person.photo_url = session[:photo_person]

      # 入力値をDBに格納できる形式に加工する
      # Person
      # よみがな
      if params[:kana].present?
        @person.alternate_names = params[:kana][:family_name] + " " + params[:kana][:given_name]
      end

      @person.save

      # 新規情報の場合
      if @clone_clone_input
        @person.source_url = url_for(:action => :view, :id => @person.id, :only_path => false)
        @person.save
      end

      # Noteの登録
      if params[:note].present?
        @note = Note.new(params[:note])
        @note.person_record_id = @person.id
        @note.photo_url = session[:photo_note]
        @note.save!
      end

      # 利用規約のチェック判定
      unless @consent
        raise ConsentError
      end
    end
   
    if @subscribe
      session[:person_id] = [@person.id]
      session[:note_id]   = [@note.try(:id)]
      redirect_to :action => "subscribe_email"
    else
      redirect_to :action => "view", :id => @person
    end

  rescue ConsentError
    flash.now[:error] = I18n.t("activerecord.errors.messages.disagree")
    render :action => "new_preview"
  end

  # 詳細画面
  # === Args
  # _id_ :: Person.id
  # _role_ :: 画面種別
  # _name_ :: 検索画面の検索条件
  # _family_name_ :: 安否情報対象者入力画面の検索条件
  # _given_name_  :: 安否情報対象者入力画面の検索条件
  # _duplication_ :: 重複Noteの表示有無
  # === Return
  # === Raise
  def view
    @person = Person.find(params[:id])
    @note = Note.new
    session[:action] = action_name

    # 検索画面に戻る用
    @action = params[:role].present? ? params[:role] : nil
    @query = params[:name]
    @query_family = params[:family_name]
    @query_given  = params[:given_name]

    @dup_flag = Person.check_dup(params[:id])  # 重複の有無
    @dup_people = Person.duplication(params[:id]) # personと重複するperson
    @subscribe = false
    # 重複メモを表示するか
    if params[:duplication].present?
      @notes = Note.where(:person_record_id => @person.id).order("entry_date ASC")
    else
      @notes = Note.no_duplication(@person.id)
    end
  end

  # 安否情報表示詳細画面（モバイル）
  # === Args
  # _id_ :: Person.id
  # _role_ :: 画面種別
  # _name_ :: 検索画面の検索条件
  # _family_name_ :: 安否情報対象者入力画面の検索条件
  # _given_name_  :: 安否情報対象者入力画面の検索条件
  # _duplication_ :: 重複Noteの表示有無
  # === Return
  # === Raise
  def note_new
    @person = Person.find(params[:id])
    @note = Note.new
    session[:action] = action_name

    # 検索画面に戻る用
    @action = params[:role].present? ? params[:role] : nil
    @query = params[:name]
    @query_family = params[:family_name]
    @query_given  = params[:given_name]

    @dup_flag = Person.check_dup(params[:id])  # 重複の有無
    @dup_people = Person.duplication(params[:id]) # personと重複するperson
    @subscribe = false
    # 重複メモを表示するか
    if params[:duplication].present?
      @notes = Note.where(:person_record_id => @person.id).order("entry_date ASC")
    else
      @notes = Note.no_duplication(@person.id)
    end
  end

  # 安否情報表示詳細画面（モバイル）
  # === Args
  # _id_ :: Person.id
  # _role_ :: 画面種別
  # _name_ :: 検索画面の検索条件
  # _family_name_ :: 安否情報対象者入力画面の検索条件
  # _given_name_  :: 安否情報対象者入力画面の検索条件
  # _duplication_ :: 重複Noteの表示有無
  # === Return
  # === Raise
  def note_list
    @person = Person.find(params[:id])
    # 検索条件を保持
    @query = params[:name]
    @query_family = ""
    @query_given  = ""
    @action = action_name
    # 安否情報を検索
    @person_id = params[:person_record_id]
    @notes = Kaminari.paginate_array(Note.find_all_by_person_record_id(params[:person_record_id])).page(params[:page]).per(10)
  end

  # 安否情報詳細画面画面
  # === Args
  # _id_ :: 安否情報一覧で選択されたNote.id
  # === Return
  # === Raise
  def note_preview
    # 検索条件を保持
    @query = params[:name]
    @query_family = ""
    @query_given  = ""
    @action = action_name
    # 安否情報を検索
    @note = Note.find(params[:id])
    @person_id = @note.person_record_id
  end

  # 安否情報登録のプレビュー画面
  # === Args
  # === Return
  # === Raise
  def update_preview
    @person = Person.find_by_id(params[:id])
    if params[:extend_days].present?
      redirect_to :action => "extend_days", :id => @person
      return
    elsif params[:subscribe_email].present?
      session[:person_id] = [@person.id]
      session[:note_id] = []
      session[:action] = "view"
      redirect_to :action => "subscribe_email"
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

    @consent     = params[:consent]   == "true" ? true : false
    @subscribe   = params[:subscribe] == "true" ? true : false
    @duplication = params[:duplication]
    # 重複メモを表示するか
    if params[:duplication].present?
      @notes = Note.where(:person_record_id => @person.id).order("entry_date ASC")
    else
      @notes = Note.no_duplication(@person.id)
    end
    
    @note = Note.new(params[:note])
    @note.last_known_location  = params[:clickable_map][:location_field]
    # 入力値チェック
    @note.invalid?

    if @note.errors.messages.present?
      raise ActiveRecord::RecordInvalid.new(@note)
    end

    # 写真の実体を一時的に保管しているパスを格納する
    session[:photo_note]   = @note.photo_url

  rescue ActiveRecord::RecordInvalid
    render :action => "view"
  end


  # 安否情報登録のプレビュー画面
  # === Args
  # === Return
  # === Raise
  def update_note_preview
    @person = Person.find_by_id(params[:id])

    @consent     = params[:consent]   == "true" ? true : false
    @subscribe   = params[:subscribe] == "true" ? true : false
    @duplication = params[:duplication]

    @note = Note.new(params[:note])
    @note.last_known_location  = params[:clickable_map][:location_field]
    # 入力値チェック
    @note.invalid?

    # 新着情報受信時メールアドレスが空でないことをチェック
    if @subscribe && params[:note][:author_email].blank?
      raise EmailBlankError
    end

    if @note.errors.messages.present?
      raise ActiveRecord::RecordInvalid.new(@note)
    end

    # 写真の実体を一時的に保管しているパスを格納する
    session[:photo_note]   = @note.photo_url

    if params[:duplication].present?
      @notes = Note.where(:person_record_id => @person.id).order("entry_date ASC")
    else
      @notes = Note.no_duplication(@person.id)
    end

    Note.transaction do
      @note = Note.new(params[:note])
      @note.person_record_id = @person.id
      @note.photo_url        = session[:photo_note]
      if @note.save!
        # 新着メールを送るアドレスを抽出
        to = Person.subscribe_email_address(@person, @note)
        # Personに新着メールを送信する
        to.each do |address|
          LgdpfMailer.send_add_note(address).deliver
        end

        # 新規登録したnoteが新着メールを受け取るか
        if @subscribe
          session[:person_id] = [@person.id]
          session[:note_id] = [@note.id]
          session[:action] = action_name
          subscribe_email_note
        else
          name = params[:name].blank? ? nil : reencode_for_mobile(params[:name])
          redirect_to action: :view, id: @person, name: name, role: params[:role]
        end
      end
    end

  rescue ActiveRecord::RecordInvalid
    render :action => :note_new
  rescue EmailBlankError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_blank")
    render :action => :note_new
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :note_new
  rescue ConsentError
    flash.now[:error] = I18n.t("activerecord.errors.messages.disagree")
    render :action => :note_new
  end

  # 安否情報を追加する
  # === Args
  # _id_                 :: Person.id
  # _extend_days_        :: ボタン種別(有効期限を60日延長する)
  # _subscribe_email_    :: ボタン種別(この方の新着情報をメールで受け取る)
  # _delete_             :: ボタン種別(このレコードを削除する)
  # _note_invalid_apply_ :: ボタン種別(この記録へのメモの書き込みを禁止する)
  # _note_valid_apply_   :: ボタン種別(この記録へのメモの書き込みを許可する)
  # _note_               :: Note
  # _subscribe_          :: 新着情報受信のチェック有無
  # _consent_            :: 利用規約に同意するのチェック有無
  # _clone_              :: 新規か複製か
  # _clickable_map_      :: 最後に見かけた場所
  # _duplication_        :: 重複Noteの表示有無
  # === Return
  # === Raise
  def update
    @person = Person.find(params[:id])
    # 登録以外のボタンを押されたら別画面に遷移する
    @consent = params[:consent] == "true" ? true :false
    @subscribe = params[:subscribe]== "true" ? true : false
    if params[:duplication].present?
      @notes = Note.where(:person_record_id => @person.id).order("entry_date ASC")
    else
      @notes = Note.no_duplication(@person.id)
    end

    Note.transaction do
      @note = Note.new(params[:note])
      @note.person_record_id = @person.id
      @note.photo_url        = session[:photo_note]
      if @note.save!
        # 利用規約のチェック判定
        unless @consent
          raise ConsentError
        end
        # 新着メールを送るアドレスを抽出
        to = Person.subscribe_email_address(@person, @note)
        # Personに新着メールを送信する
        to.each do |address|
          LgdpfMailer.send_add_note(address).deliver
        end

        # 新規登録したnoteが新着メールを受け取るか
        if @subscribe
          session[:person_id] = [@person.id]
          session[:note_id] = [@note.id]
          session[:action] = action_name
          redirect_to :action => :subscribe_email
        else
          redirect_to :action => :view, :id => @person
        end
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => :update_preview
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :update_preview
  rescue ConsentError
    flash.now[:error] = I18n.t("activerecord.errors.messages.disagree")
    render :action => :update_preview

  end

  # 避難者情報保持期間延長画面
  # === Args
  # _id_     :: Person.id
  # _complete_ :: submitした場合渡されるパラメータ
  # === Return
  # === Raise
  def extend_days
    @person = Person.find(params[:id])
    if params[:complete].present?
      # 削除予定日を60日延長する
      @person.expiry_date = @person.expiry_date + 60.days
      if verify_recaptcha(:model => @person) && @person.save!
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "extend_days"}
      end
    end
  end

  # 新着情報受信許可画面
  # === Args
  # _id_       :: Person.id
  # _id2_      :: Person.id(重複)
  # _id3_      :: Person.id(重複)
  # _note_id_  :: Note.id
  # _note_id2_ :: Note.id(重複)
  # _note_id3_ :: Note.id(重複)
  # _success_  :: ボタン種別(アップデートする)
  # _cancel_   :: ボタン種別(キャンセル)
  # === Return
  # === Raise
  def subscribe_email
    @person = Person.find(session[:person_id].first)  # ウォッチする避難者
    @note = Note.find_by_id(session[:note_id].first)

    # アップデートを受け取るボタン押下
    if params[:success].present?
      if verify_recaptcha(:model => @person)
        if session[:action] == ("new" || "view") # personで新着受取チェック
          if params[:person][:author_email].blank?
            raise EmailBlankError
          end
          @person.email_flag = true
          @person.author_email = params[:person][:author_email]
          # author_emailに重複がある場合は受取フラグを消す
          if  Note.where(
              :person_record_id => @person.id,
              :author_email     => @person.author_email,
              :email_flag       => true
            ).size > 0
            @person.email_flag = false
          end
          @person.save!
        else  # noteで新着受取チェック
          if params[:note][:author_email].blank?
            raise EmailBlankError
          end

          Note.transaction do
            session[:note_id].each do |note_id|
              note = Note.find_by_id(note_id)
             
              parent_person = Person.find_by_id(note.person_record_id)
              note.author_email = params[:note][:author_email]
              # 親Personに重複するアドレスがあるか
              # 紐付くNoteに重複するアドレスがあるか
              note.email_flag = true
              if parent_person.author_email ==  note.author_email ||
                  Note.where(
                  :person_record_id => parent_person.id,
                  :author_email => note.author_email,
                  :email_flag => true
                ).size > 0
                note.email_flag = false
              end

              note.save!
            end
          end
        end

        if session[:action] == ("new" || "view")
          LgdpfMailer.send_new_information(@person, nil).deliver
        else
          session[:note_id].each do |note_id|
            note = Note.find_by_id(note_id)
            parent_person = Person.find_by_id(note.person_record_id)
            LgdpfMailer.send_new_information(parent_person, note).deliver
          end
        end
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "subscribe_email"}
      end
      # キャンセルボタン押下
    elsif params[:cancel].present?
      redirect_to :action => :view, :id => @person
    end
  rescue EmailBlankError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_blank")
    render :action => :subscribe_email
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :subscribe_email
  rescue ActiveRecord::RecordInvalid
    render :action => :subscribe_email
  end

  # 新着情報受信許可処理（モバイル）
  # === Args
  # _id_       :: Person.id
  # _id2_      :: Person.id(重複)
  # _id3_      :: Person.id(重複)
  # _note_id_  :: Note.id
  # _note_id2_ :: Note.id(重複)
  # _note_id3_ :: Note.id(重複)
  # === Return
  # === Raise
  def subscribe_email_person
    @person = Person.find(session[:person_id].first)  # ウォッチする避難者

    @person.email_flag = true
    @person.author_email = params[:person][:author_email]
    # author_emailに重複がある場合は受取フラグを消す
    if  Note.where(
        :person_record_id => @person.id,
        :author_email     => @person.author_email,
        :email_flag       => true
      ).size > 0
      @person.email_flag = false
    end
    @person.save!

    LgdpfMailer.send_new_information(@person, nil).deliver

    redirect_to :action => :complete,
      :id => @person,
      :complete => {:key => "subscribe_email"}

  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :new
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end

  # 新着情報受信許可処理（モバイル）
  # === Args
  # _id_       :: Person.id
  # _id2_      :: Person.id(重複)
  # _id3_      :: Person.id(重複)
  # _note_id_  :: Note.id
  # _note_id2_ :: Note.id(重複)
  # _note_id3_ :: Note.id(重複)
  # === Return
  # === Raise
  def subscribe_email_note
    @person = Person.find(session[:person_id].first)  # ウォッチする避難者
    @note = Note.find_by_id(session[:note_id].first)
    
    Note.transaction do
      session[:note_id].each do |note_id|
        note = Note.find_by_id(note_id)
        parent_person = Person.find_by_id(note.person_record_id)
        note.author_email = params[:note][:author_email]
        # 親Personに重複するアドレスがあるか
        # 紐付くNoteに重複するアドレスがあるか
        note.email_flag = true
        if parent_person.author_email ==  note.author_email ||
          Note.where(
            :person_record_id => parent_person.id,
            :author_email => note.author_email,
            :email_flag => true
          ).size > 0
          note.email_flag = false
        end
        
        note.save!
      end
    end
    
    session[:note_id].each do |note_id|
      note = Note.find_by_id(note_id)
      parent_person = Person.find_by_id(note.person_record_id)
      LgdpfMailer.send_new_information(parent_person, note).deliver
    end
    
    redirect_to :action => :complete,
      :id => @person,
      :complete => {:key => "subscribe_email"}

  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :note_new
  rescue ActiveRecord::RecordInvalid
    render :action => :note_new
  end

  # 新着情報受信拒否
  # === Args
  # _id_      :: Person.id
  # _note_id_ :: Note.id
  # === Return
  # === Raise
  def unsubscribe_email
    @person = params[:id].present?
    @person = Person.find(params[:id])
    if params[:note_id].present?
      # noteへの新着メールを停止する
      @note = Note.find(params[:note_id])
      @note.email_flag = false
      @note.save!
    else
      # personへの新着メールを停止する
      @person.email_flag = false
      @person.save!
    end
    redirect_to :action => :complete,
      :id => @person,
      :complete => {:key => "unsubscribe_email"}
  end

  # 避難者情報削除画面
  # === Args
  # _id_     :: Person.id
  # _complete_ :: submitした場合渡されるパラメータ
  # === Return
  # === Raise
  def delete
    @person = Person.find(params[:id])
    if params[:complete].present?
      if verify_recaptcha(:model => @person)
        @person.destroy
        LgdpfMailer.send_delete_notice(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "delete"}
      end
    end
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :delete
  end

  # 削除データ復元画面
  # === Args
  # _id_     :: Person.id
  # _complete_ :: submitした場合渡されるパラメータ
  # === Return
  # === Raise
  def restore
    # 削除されたデータも含め全件から抽出する
    @person = Person.with_deleted.find(params[:id])
    if params[:complete].present?
      # POST
      if verify_recaptcha(:model => @person)
        @person.recover
        LgdpfMailer.send_restore_notice(@person).deliver
        redirect_to :action => :view, :id => @person
      end
    else
      # GET
      if @person.deleted_at.blank?  # 復元されている場合
        redirect_to :action => :view, :id => @person
      end
    end
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :restore
  end

  # 安否情報登録無効申請画面
  # === Args
  # _id_     :: Person.id
  # _complete_ :: submitした場合渡されるパラメータ
  # === Return
  # === Raise
  def note_invalid_apply
    @person = Person.find(params[:id])
    if params[:complete].present?
      if verify_recaptcha(:model => @person)
        LgdpfMailer.send_note_invalid_apply(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "note_invalid_apply"}
      end
    end
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :note_invalid_apply
  end

  # 安否情報登録無効画面
  # === Args
  # _id_     :: Person.id
  # _complete_ :: ボタン種別
  # === Return
  # === Raise
  def note_invalid
    @person = Person.find(params[:id])
    if params[:complete].present?
      @person.notes_disabled = true
      if @person.save!
        LgdpfMailer.send_note_invalid(@person).deliver
        redirect_to :action => :view, :id => @person
      end
    end
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :note_invalid
  end

  # 安否情報登録有効申請画面
  # === Args
  # _id_     :: Person.id
  # _complete_ :: submitした場合渡されるパラメータ
  # === Return
  # === Raise
  def note_valid_apply
    @person = Person.find(params[:id])
    if params[:complete].present?
      if verify_recaptcha(:model => @person)
        LgdpfMailer.send_note_valid_apply(@person).deliver
        redirect_to :action => :complete,
          :id => @person,
          :complete => {:key => "note_valid_apply"}
      end
    end
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :note_valid_apply
  end

  # 安否情報登録有効画面
  # === Args
  # _id_ :: Person.id
  # === Return
  # === Raise
  def note_valid
    @person = Person.find(params[:id])
    @person.notes_disabled = false
    if @person.save!
      LgdpfMailer.send_note_valid(@person).deliver
      redirect_to :action => :view, :id => @person
    end
  rescue Net::SMTPFatalError
    flash.now[:error] = I18n.t("activerecord.errors.messages.email_invalid")
    render :action => :note_valid
  end

  # スパム報告画面
  # === Args
  # _id_      :: Person.id
  # _note_id_ :: Note.id
  # _complete_  :: ボタン種別
  # === Return
  # === Raise
  def spam
    @person = Person.find(params[:id])
    @note = Note.find(params[:note_id])
    session[:action] = action_name
    if params[:complete].present?
      @note.spam_flag = true  # 認定:true, 取消:false
      if @note.save!
        redirect_to :action => :view, :id => @person
      end
    end
  end

  # スパム報告取消画面
  # === Args
  # _id_      :: Person.id
  # _note_id_ :: Note.id
  # _complete_  :: ボタン種別
  # === Return
  # === Raise
  def spam_cancel
    @person = Person.find(params[:id])
    @note = Note.find(params[:note_id])
    session[:action] = action_name
    if params[:complete].present?
      @note.spam_flag = false  # 認定:true, 取消:false
      if verify_recaptcha(:model => @person) && @note.save!
        redirect_to :action => :view, :id => @person
      end
    end
  end

  # 個人情報表示許可画面
  # === Args
  # _id_      :: Person.id
  # _id2_     :: Person.id(重複)
  # _id3_     :: Person.id(重複)
  # _note_id_ :: Note.id
  # _complete_ :: submitした場合渡されるパラメータ
  # === Return
  # === Raise
  def personal_info
    @person = Person.find(params[:id])
    @note = Note.find(params[:note_id]) unless params[:note_id].blank?
    @id2 = params[:id2]
    @id3 = params[:id3]

    if params[:complete].present?
      if verify_recaptcha(:model => @person)
        session[:pi_view] = true
        if session[:action] == ("spam" || "spam_cancel")
          redirect_to :action => session[:action], :id => @person, :note_id => @note
        elsif session[:action] == "multiviews"
          redirect_to :action => session[:action], :id => @person, :note_id => @note,
            :id1 => @person.id, :id2 => @id2, :id3 => @id3
        else
          redirect_to :action => session[:action], :id => @person
        end
      end
    end
  end


  # 完了画面
  # === Args
  # _id_ :: Person.id
  # _complete_ :: 設定種別
  # === Return
  # === Raise
  def complete
    @key = params[:complete][:key]
    if @key == "delete"
      @person = Person.with_deleted.find(params[:id])
    else
      @person = Person.find(params[:id])
    end
  end

  private

  # profile_urlsをDBに登録できる形に整形する
  # === Args
  # _profile_url1_ :: プロフィール1件目
  # _profile_url2_ :: プロフィール2件目
  # _profile_url3_ :: プロフィール3件目
  # === Return
  # 3件を結合した文字列
  # === Raise
  def set_profile_urls
    urls = [params[:profile_url1], params[:profile_url2], params[:profile_url3]]
    urls.delete("")
    return urls.join("\n")
  end

  
end
