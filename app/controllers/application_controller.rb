# -*- coding:utf-8 -*-
class ApplicationController < ActionController::Base
  before_filter :init, :expiry_date, :cancel_personal_info

  protect_from_forgery

  # コンスタントマスタの読み込み
  def init
    # セレクトボックスの表示に使用するコンスタントテーブルの取得
    @person_const = Constant.get_const(Person.table_name)
    @note_const   = Constant.get_const(Note.table_name)
    # memcacheからマスタを取得
    # @area = get_cache("area")
    # @address = Rails.cache.read("address")
    # @shelter = get_cache("shelter")
  end

  # 有効期限の確認
  # === Args
  # _token_ :: ユニークキー
  # === Raise
  # ActiveRecord::RecordNotFound
  def expiry_date
    if params[:token].present?
      aal = ApiActionLog.where(:unique_key => params[:token])
      # tokenが空か、作成してから３日より経過していたら例外
      if aal.blank? || (aal[0].entry_date + 3.days) < Time.now
        raise ActiveRecord::RecordNotFound
      end
    end
    return nil
  end

  # 個人情報表示を無効にする
  # submitしたときに個人情報を非表示にする
  def cancel_personal_info
    # submitボタン押下
    if params[:commit].present?
      session[:pi_view] = false  # 個人情報表示を無効にする
    end
  end

  # 利用規約画面
  def terms_of_service
    f = open("#{Rails.root}/config/terms_message.txt")
    @terms_message =  f.read
    f.close
  end


  # memcacheされた値を取得・加工
  # === Args
  # _key_name_ :: キャッシュされているハッシュのキー名
  # === Return
  # _constant_list_ :: {code => name}
  # ==== Raise
  def get_cache(key_name)
    constant_list = {}
    constant = Rails.cache.read(key_name)
    constant.each do |c|
      constant_list[c[0]] = c[1]["name"]
    end
    return constant_list
  end


  # オートコンプリート市区町村取得処理
  # ==== Args
  # _term_ :: ユーザ入力値
  # _state_ :: 都道府県
  # ==== Return
  # 市区町村jsonオブジェクト
  # ==== Raise
  def autocomplete_city
    @city = Rails.cache.read("city")
    @city.delete_if{|key,value| value !~ /#{params["term"]}/}

    respond_to do |format|
      format.json { render :json => (@city.present? ? @city.values.to_json : Hash.new) }
    end
  end

  # オートコンプリート町名取得処理
  # ==== Args
  # _term_ :: ユーザ入力値
  # _state_ :: 都道府県
  # ==== Return
  # 町名jsonオブジェクト
  # ==== Raise
  def autocomplete_street
    @street = Rails.cache.read("street")
    @street.delete_if{|key,value| value !~ /#{params["term"]}/}

    respond_to do |format|
      format.json { render :json => (@street.present? ? @street.values.to_json : Hash.new) }
    end
  end

  # レコードが削除されていた場合の処理
  rescue_from ActiveRecord::RecordNotFound do
    render :file => "#{Rails.root}/public/404.html"
  end

end
