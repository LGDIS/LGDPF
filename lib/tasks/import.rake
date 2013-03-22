# -*- coding: utf-8 -*-
namespace :import do

  desc "restore shelters from redmine."
  task :shelters => :environment do

    Rails.logger.info " #{Time.now} ===== START ===== "
    environments = Dir.glob("config/environments/*.rb").map {|f| File.basename(f, ".rb")}
    environments.delete_if {|env| env=~ /\A(test|develop)/} # exclude test/development environments
    environments.each do |environment|
      begin
        stdout = `cd #{Rails.root}; RAILS_ENV=#{environment} rails runner Batches::ImportShelters.execute`
        Rails.logger.info stdout
      rescue => e
        Rails.logger.error "#{e.class}:#{e.message}"
      end
    end
    Rails.logger.info " #{Time.now} =====  END  ===== "
  end
end
