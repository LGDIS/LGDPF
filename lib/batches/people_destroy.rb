# -*- coding:utf-8 -*-
# 避難者情報削除バッチ
# ==== バッチの実行コマンド
# rails runner Batches::PeopleDestroy.execute
# ==== options
# 実行環境の指定 :: -e production

class Batches::PeopleDestroy
  def self.execute
    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} START ===== ")

    Person.destroy_all(["expiry_date > ?", Time.now])

    Rails.logger.info(" #{Time.now.to_s} ===== #{self.name} END ===== ")
  end
end