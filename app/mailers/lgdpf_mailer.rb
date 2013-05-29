# -*- coding:utf-8 -*-
class LgdpfMailer < Jpmobile::Mailer::Base

  # メールのfrom名設定
  default from: SETTINGS["mail"]["sender"]

  # 新着情報を受け取るように設定したことを確認するメールを送信する
  # === Args
  # _person_       :: 新着情報をウォッチする避難者
  # _note_         :: 新着情報をウォッチするノート
  # _subscription_ :: 新着情報をウォッチする購読情報
  # === Return
  # === Raise
  def send_new_information(person, note, subscription)

    # ユニークキーの設定
    aal = ApiActionLog.create

    @person = person

    # この情報元のURL作成
    @view_path = SETTINGS["mail"]["host"] + "/people/view/" + @person.id.to_s

    # 購読解除URLの作成
    # 送信先の決定
    if note.present? 
      note_id = note.id
      @unsubscribe_email_path = SETTINGS["mail"]["host"] + "/person/unsubscribe_email?id=" + @person.id.to_s +
        "&note_id=" + note_id.to_s + "&token=" + aal.unique_key
      address = note.author_email
      email_flag = note.email_flag
    elsif subscription.present?
      subscription_id = subscription.id
      @unsubscribe_email_path = SETTINGS["mail"]["host"] + "/person/unsubscribe_email?id=" + @person.id.to_s +
        "&subscription_id=" + subscription_id.to_s + "&token=" + aal.unique_key
      address = subscription.author_email
      email_flag = true
    else
      @unsubscribe_email_path = SETTINGS["mail"]["host"] + "/person/unsubscribe_email?id=" + @person.id.to_s + "&token=" + aal.unique_key
      address = @person.author_email
      email_flag = @person.email_flag
    end

    # 題名
    subject = @person.full_name + "さんについての新着情報を受け取るように設定しました"

    # 受信フラグがtrueの場合にメールを送信する
    if email_flag
      mail(:to => address, :subject => subject)
    end

  end

  # 新着情報
  # === Args
  # _target_ :: 送信対象
  # _[0]_    :: 新着情報をウォッチする避難者
  # _[1]_    :: 追加されたNote
  # _[2]_    :: 送信メールアドレス
  # === Return
  # === Raise
  def send_add_note(target)

    # ユニークキーの設定
    aal = ApiActionLog.create

    # Personオブジェクト
    @person = target[0]

    # Noteオブジェクト
    @note = target[1]

    # Person or Note or Subscription オブジェクト
    record_type = target[2]

    @note_const = Constant.get_const(Note.table_name)

    # この情報元のURL作成
    @view_path = SETTINGS["mail"]["host"] + "/people/view/" + @person.id.to_s

    # Noteに送る場合
    if record_type.is_a? Note
      note_id = record_type.id
      @unsubscribe_email_path = SETTINGS["mail"]["host"] + "/person/unsubscribe_email?id=" + @person.id.to_s +
        "&note_id=" + note_id.to_s + "&token=" + aal.unique_key
    elsif record_type.is_a? Subscription
      subscription_id = record_type.id
      @unsubscribe_email_path = SETTINGS["mail"]["host"] + "/person/unsubscribe_email?id=" + @person.id.to_s +
        "&subscription_id=" + subscription_id.to_s + "&token=" + aal.unique_key
    else
      @unsubscribe_email_path = SETTINGS["mail"]["host"] + "/person/unsubscribe_email?id=" + @person.id.to_s + "&token=" + aal.unique_key
    end
    address = record_type.author_email

    # 題名
    subject = @person.full_name + "さんについての新着情報"

    # メールを送信する
    mail(:to => address, :subject => subject)
  end

  # 避難者のレコードが削除されたことを通知するメールを送信する
  # === Args
  # _person_ :: 削除された避難者
  # === Return
  # === Raise
  def send_delete_notice(person)
    aal = ApiActionLog.create
    @person = person
    @root_path = SETTINGS["mail"]["host"]
    @restore_path = SETTINGS["mail"]["host"] + "/person/restore?id=" + @person.id.to_s + "&token=" + aal.unique_key
    subject = person.full_name + "さんの削除の通知"

    # 受信フラグがtrueの場合にメールを送信する
    if @person.email_flag
      mail(:to => @person.author_email, :subject => subject)
    end
  end

  # 削除されたレコードが復元したことを通知するメールを送信する
  # === Args
  # _person_ :: 復元する避難者
  # === Return
  # === Raise
  def send_restore_notice(person)
    @person = person
    @view_path = SETTINGS["mail"]["host"] + "/people/view/" + @person.id.to_s
    subject = person.full_name + "さんの記録の復元の通知"

    # 受信フラグがtrueの場合にメールを送信する
    if @person.email_flag
      mail(:to => @person.author_email, :subject => subject)
    end
  end

  # 安否情報登録無効申請
  # === Args
  # _person_ :: メモ登録を無効にする避難者
  # === Return
  # === Raise
  def send_note_invalid_apply(person)
    aal = ApiActionLog.create
    @person = person
    @invalid_path = SETTINGS["mail"]["host"] + "/person/note_invalid?id=" + @person.id.to_s + "&token=" + aal.unique_key

    subject = "「" + person.full_name + "」さんに関するメモを無効にしますか? "

    # 受取フラグに関係なく、メールを送信する。
    mail(:to => @person.author_email, :subject => subject)
  end

  # 安否情報登録無効にしたことを確認するメールを送信する
  # === Args
  # _person_ :: メモ登録を無効にした避難者
  # === Return
  # === Raise
  def send_note_invalid(person)
    @person = person
    @view_path = SETTINGS["mail"]["host"] + "/people/view/" + @person.id.to_s
    subject = "「" + person.full_name + "」さんに関するメモが無効になりました "

    # 受取フラグに関係なく、メールを送信する。
    mail(:to => @person.author_email, :subject => subject)
  end

  # 安否情報登録有効申請
  # === Args
  # _person_ :: メモ登録を有効にする避難者
  # === Return
  # === Raise
  def send_note_valid_apply(person)
    aal = ApiActionLog.create
    @person = person
    @valid_path = SETTINGS["mail"]["host"] + "/person/note_valid?id=" + @person.id.to_s + "&token=" + aal.unique_key
    subject = "「" + person.full_name + "」さんに関するメモを有効にしますか? "

    # 受取フラグに関係なく、メールを送信する。
    mail(:to => @person.author_email, :subject => subject)
  end

  # 安否情報登録有効にしたことを確認するメールを送信する
  # === Args
  # _person_ :: メモ登録を有効にした避難者
  # === Return
  # === Raise
  def send_note_valid(person)
    @person = person
    @view_path = SETTINGS["mail"]["host"] + "/people/view/" + @person.id.to_s
    subject = "「" + person.full_name + "」さんに関するメモが有効になりました "

    # 受取フラグに関係なく、メールを送信する。
    mail(:to => @person.author_email, :subject => subject)
  end

  # ActionMailer::Base#mailメソッド
  # 送信メールの件名先頭に固定文字列を追加する
  # === Args
  # _headers_ :: headers in an email message
  # _block_ ::  render specific templates if you do pass a block
  # === Return
  # === Raise
  def mail(headers={}, &block)
    if headers.has_key?(:subject)
      headers[:subject] = I18n.t("mail.subject_prefix.run_mode_#{CURRENT_RUN_MODE}") + headers[:subject].to_s
    end
    super
  end
end
