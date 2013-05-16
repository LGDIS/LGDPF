# encoding: utf-8


shared_context "carrier_wave_context" do
  include CarrierWave::Test::Matchers

  before(:all) do
    CarrierWave.configure do |config|
      config.storage = :file
      config.enable_processing = false
    end
    CarrierWave::Uploader::Base.descendants.each do |klass|
      next if klass.anonymous?
      klass.class_eval do
        def cache_dir
          "#{Rails.root}/spec/support/uploads/tmp"
        end 
        def store_dir
          "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end 
      end 
    end 
  end

  before do
    described_class.enable_processing = true
  end

  after do
    described_class.enable_processing = false
  end

  after(:all) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
  end 

end
