# coding: utf-8
module PersonHelper
  # 検索結果に表示する姓名文字列を生成する
  # == Args
  # _person_ :: Person
  # == Return
  # 姓名文字列
  def create_result_data_title(person)
    if person.alternate_names.present?
      return "#{person.full_name} (#{person.alternate_names})"
    else
      return person.full_name
    end
  end
  
  # 検索結果に表示する住所文字列を生成する
  # == Args
  # _person :: Person
  # == Return
  # 住所文字列
  def create_address(person)
    address_ary = []
    join_str = "&nbsp;&nbsp;&nbsp;"
    
    # 町名
    address_ary << person.home_street if person.home_street.present?
    # 近隣の場所
    address_ary << person.home_neighborhood if person.home_neighborhood.present?
    # 市
    address_ary << person.home_city if person.home_city.present?
    # 都道府県
    address_ary << person.home_state if person.home_state.present?
    # 郵便番号
    address_ary << person.home_postal_code if person.home_postal_code.present?
    
    if address_ary.present?
      # 住所文字列をHTMLエスケープする
      address_ary.map!{|adr| ERB::Util.html_escape(adr) }
      return ("自宅住所: " + address_ary.join(join_str)).html_safe
    else
      return nil
    end
  end

  # 改行コードをHTMLの改行タグに変換する
  # === Args
  # _str_ :: 変換する文字列
  # 
  def parse_br(str)
    str = html_escape(str)
    return str.gsub(/(\r\n|\r|\n)/, "<br />")
  end

  
end
