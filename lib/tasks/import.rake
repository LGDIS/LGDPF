# -*- coding: utf-8 -*-
namespace :import do

  desc "restore shelters from redmine."
  task :shelters => :environment do
    Rails.logger.info " #{Time.now} ===== START ===== "
    Rails.logger.info Batches::ImportShelters.execute
    Rails.logger.info " #{Time.now} =====  END  ===== "
  end
end
