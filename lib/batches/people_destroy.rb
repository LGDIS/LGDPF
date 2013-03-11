# -*- coding:utf-8 -*-
# 避難者情報削除バッチ
# ==== バッチの実行コマンド
# rails runner Batches::PeopleDestroy.execute
# ==== options
# 実行環境の指定 :: -e production

class Batches::PeopleDestroy
  def self.execute
    puts(" #{Time.now.to_s} ===== #{self.name} START ===== ")

    # 現在日時より削除予定日時のほうが過去の場合削除する
    Person.destroy_all(["expiry_date < ?", Time.now])

    puts(" #{Time.now.to_s} ===== #{self.name} END ===== ")
  end
end