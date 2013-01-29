# -*- coding:utf-8 -*-
class LgdpfMailer < Jpmobile::Mailer::Base
  @@settings = YAML.load_file("#{Rails.root}/config/settings.yml")
  default from: @@settings["ldgpf"]["mail"]["from"]

  # 新着情報を受け取るように設定したことを確認するメールを送信する
  # ==== Args
  # _person_ :: 新着情報をウォッチする避難者
  #
  def send_new_information(person, note)
    aal = ActiveRecord::Base::ApiActionLog.create
    @person = person
    @view_path = @@settings["ldgpf"][Rails.env]["site"] + "people/view/"+ @person.id.to_s
    @complete_path = @@settings["ldgpf"][Rails.env]["site"] +
      "person/complete?complete[key]=unsubscribe_email&id=" +
      @person.id.to_s + "&token=" + aal.unique_key
    subject = "[パーソンファインダー]" + person.full_name + "さんについての新着情報を受け取るように設定しました"
    if note.blank?
      address = @person.author_email
    else
      address = note.author_email
    end

    mail(:to => address, :subject => subject)
  end

  # 新着情報
  # ==== Args
  # _person_  :: 新着情報をウォッチする避難者
  # _note_    :: Note
  # _address_ :: 送信メールアドレス
  #
  def send_add_note(person, note, address)
    aal = ActiveRecord::Base::ApiActionLog.create
    @person = person
    @note = note
    @note_const = Constant.get_const(Note.table_name)
    @view_path = @@settings["ldgpf"][Rails.env]["site"] + "people/view/"+ @person.id.to_s
    @unsubscribe_path = @@settings["ldgpf"][Rails.env]["site"] +
      "person/complete?complete[key]=unsubscribe_email&id=" +
      @person.id.to_s + "&token=" + aal.unique_key

    subject = "[パーソンファインダー]" + person.full_name + "さんについての新着情報"

    mail(:to => address, :subject => subject)
  end

  # 避難者のレコードが削除されたことを通知するメールを送信する
  # ==== Args
  # _person_ :: 削除された避難者
  #
  def send_delete_notice(person)
    aal = ActiveRecord::Base::ApiActionLog.create
    @person = person
    @root_path = @@settings["ldgpf"][Rails.env]["site"]
    @restore_path = @@settings["ldgpf"][Rails.env]["site"] +
      "person/restore?id="+ @person.id.to_s + "&token=" + aal.unique_key

    subject = "[パーソンファインダー]" + person.full_name + "さんの削除の通知"
    mail(:to => @person.author_email, :subject => subject)
  end

  # 削除されたレコードが復元したことを通知するメールを送信する
  # ==== Args
  # _person_ :: 復元する避難者
  #
  def send_restore_notice(person)
    @person = person
    @view_path = @@settings["ldgpf"][Rails.env]["site"] + "people/view/"+ @person.id.to_s

    subject = "[パーソンファインダー]" + person.full_name + "さんの記録の復元の通知"
    mail(:to => @person.author_email, :subject => subject)
  end

  # 安否情報登録無効申請
  # ==== Args
  # _person_ :: メモ登録を無効にする避難者
  #
  def send_note_invalid_apply(person)
    aal = ActiveRecord::Base::ApiActionLog.create
    @person = person
    @invalid_path = @@settings["ldgpf"][Rails.env]["site"] +
      "person/note_invalid?id="+ @person.id.to_s + "&token=" + aal.unique_key

    subject = "[パーソンファインダー]「" + person.full_name + "」さんに関するメモを無効にしますか? "
    mail(:to => @person.author_email, :subject => subject)
  end

  # 安否情報登録無効にしたことを確認するメールを送信する
  # ==== Args
  # _person_ :: メモ登録を無効にした避難者
  #
  def send_note_invalid(person)
    @person = person
    @view_path = @@settings["ldgpf"][Rails.env]["site"] + "people/view/"+ @person.id.to_s

    subject = "[パーソンファインダー]「" + person.full_name + "」さんに関するメモが無効になりました "
    mail(:to => @person.author_email, :subject => subject)
  end

  # 安否情報登録有効申請
  # ==== Args
  # _person_ :: メモ登録を有効にする避難者
  #
  def send_note_valid_apply(person)
    aal = ActiveRecord::Base::ApiActionLog.create
    @person = person
    @valid_path = @@settings["ldgpf"][Rails.env]["site"] +
      "person/note_valid?id="+ @person.id.to_s + "&token=" + aal.unique_key

    subject = "[パーソンファインダー]「" + person.full_name + "」さんに関するメモを有効にしますか? "
    mail(:to => @person.author_email, :subject => subject)
  end

  # 安否情報登録有効にしたことを確認するメールを送信する
  # ==== Args
  # _person_ :: メモ登録を有効にした避難者
  #
  def send_note_valid(person)
    @person = person
    @view_path = @@settings["ldgpf"][Rails.env]["site"] + "people/view/"+ @person.id.to_s

    subject = "[パーソンファインダー]「" + person.full_name + "」さんに関するメモが有効になりました "
    mail(:to => @person.author_email, :subject => subject)
  end


end
