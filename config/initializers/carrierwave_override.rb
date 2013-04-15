# -*- coding:utf-8 -*-

module CarrierWave
  module Uploader
    module Download
      class RemoteFile
        private
        def file_with_i18n
          file_without_i18n
        rescue CarrierWave::DownloadError
          raise CarrierWave::DownloadError,  I18n.t("activerecord.errors.messages.record_invalid")
        end
        alias_method_chain :file, :i18n
      end

      def download_with_i18n!(uri)
        download_without_i18n!(uri)
      rescue CarrierWave::DownloadError
        raise CarrierWave::DownloadError,  I18n.t("activerecord.errors.messages.record_invalid")
      end
      alias_method_chain :download!, :i18n
    end
  end
end
