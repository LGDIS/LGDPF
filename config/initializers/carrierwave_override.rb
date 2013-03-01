# -*- coding:utf-8 -*-

module CarrierWave
  module Uploader
    module Download
      class RemoteFile
        # 特異メソッド
        # エラーメッセージを日本語にする
        def file_with_japanize
          file_without_japanize
        rescue Exception => e
          raise CarrierWave::DownloadError,  I18n.t("activerecord.errors.messages.record_invalid")
        end

        alias_method_chain :file, :japanize
        
      end
    end
  end
end
