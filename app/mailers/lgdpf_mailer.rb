# -*- coding:utf-8 -*-
class LgdpfMailer < Jpmobile::Mailer::Base
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

    mail(:to => @person.author_email, :subject => subject)
  end

  # 避難者のレコードが削除されたことを通知するメールを送信する
  # ==== Args
  # _person_ :: 削除された避難者
  #
  def send_delete_notice(person)
    @person = person
    @root_path = @@settings["ldgpf"][Rails.env]["site"]
    @restore_path = @@settings["ldgpf"][Rails.env]["site"] + "person/restore?id="+ @person.id.to_s

    subject = "[パーソンファインダー]" + person.full_name + "さんの削除の通知"
    mail(:to => @person.author_email, :subject => subject)
  end

end
