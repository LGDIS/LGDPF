# -*- coding:utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  # memcacheされた値を取得・加工
  # === Args
  # _key_name_ :: キャッシュされているハッシュのキー名
  # === Return
  # _constant_list_ :: {code => name}
  #
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
