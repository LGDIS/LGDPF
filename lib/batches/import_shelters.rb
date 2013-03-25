# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::ImportShelters.execute

require 'csv'

class Batches::ImportShelters < ActiveRecord::Base

  FILE_PREFIX = "_xA9z94_"

  def self.execute
    puts "environment: #{Rails.env}"
    remote_uri = SETTINGS["shelter_source"]["uri"]
    remote_timeout = SETTINGS["shelter_source"]["timeout"].to_i
    basic_auth_username = SETTINGS["shelter_source"]["basic_auth"]["username"]
    basic_auth_password = SETTINGS["shelter_source"]["basic_auth"]["password"]
    if remote_uri.blank?
      puts " no shelter_source supplied."
      return
    end
    input_file = "#{FILE_PREFIX}#{Rails.env}.csv"
    begin
      # retrieve csv-data
      input_data = ""
      timeout(remote_timeout) do
        basic_auth = "--basic --user #{basic_auth_username}:#{basic_auth_password}" if basic_auth_username.present?
        input_data = `curl --silent #{basic_auth} #{remote_uri + input_file}`
      end
      # import to database
      if !$?.success? || input_data.empty?
        puts " no rows retrieved."
      else
        Shelter.transaction do
          before_rows_count = Shelter.count
          Shelter.delete_all
          CSV.parse(input_data, csv_option) do |csv_reader|
            Shelter.new(Hash[csv_reader]).save!(:validate => false)
          end
          after_rows_count = Shelter.count
          puts " imported.(#{before_rows_count} rows delete, #{after_rows_count} rows insert)"
        end
      end
    rescue => e
      puts "ERROR: #{e.class}: #{e.message}"
    end
  end

  def self.csv_option
    {
      :encoding => "UTF-8",
      :headers => :first_row,
      :quote_char => '"',
      :force_quotes => true,
    }
  end
end
