# -*- coding:utf-8 -*-
class LpfMailer < Jpmobile::Mailer::Base
  settings = YAML.load_file("#{Rails.root}/config/settings.yml")
  default from: settings["ldgpf"]["mail"]["from"]

  # 新着情報を受け取るように設定したことを確認するメールを送信する
  # ==== Args
  # _person_ :: 新着情報をウォッチする避難者
  #
  def send_new_information(person)
      @person = person
      subject = "[パーソンファインダー]" + person.full_name + "さんについての新着情報を受け取るように設定しました"

#    mail(:to => "fb020@adniss.biz.ezweb.ne.jp", :subject => subject)
    mail(:to => "Nakamura.Tomoya@adniss.jp", :subject => subject)
  end
end
