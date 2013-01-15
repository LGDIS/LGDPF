# -*- coding:utf-8 -*-
class LpfMailer < Jpmobile::Mailer::Base
  @@settings = YAML.load_file("#{Rails.root}/config/settings.yml")
  default from: @@settings["ldgpf"]["mail"]["from"]

  # 新着情報を受け取るように設定したことを確認するメールを送信する
  # ==== Args
  # _person_ :: 新着情報をウォッチする避難者
  #
  def send_new_information(person)
    @person = person
    @view_path = @@settings["ldgpf"][Rails.env]["site"] + "people/view/"+ @person.id.to_s
    @complete_path = @@settings["ldgpf"][Rails.env]["site"] +
      "person/complete?complete[key]=unsubscribe_email&id=" +
      @person.id.to_s
    subject = "[パーソンファインダー]" + person.full_name + "さんについての新着情報を受け取るように設定しました"

#    mail(:to => @person.author_email, :subject => subject)
    mail(:to => "nakatyu-3126@docomo.ne.jp", :subject => subject)
  end
end
