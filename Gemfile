source 'http://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Pg is the Ruby interface to the PostgreSQL RDBMS.
# It works with PostgreSQL 8.3 and later.
gem "pg"

# ActiveRecord extension to get more from PostgreSQL.
gem 'pg_power'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# CarrierWave is Upload files in your Ruby applications, map them
# to a range of ORMs, store them on different backends.
gem 'carrierwave'

# If you're uploading images by CarrierWave, you'll probably want to
# manipulate them in some way, you might want to create thumbnail images
# for example. CarrierWave comes with a small library to make manipulating
# images with RMagick easier.
gem 'rmagick', '>= 2.0.0'

# recaptcha adds helpers for the reCAPTCHA API.
gem 'recaptcha', :require => 'recaptcha/rails'

# Dalli is a high performance pure Ruby client for accessing memcached servers.
gem 'dalli'

# Load Local Gemfile
local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exists?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end

# Load plugins' Gemfiles
Dir.glob File.expand_path("../plugins/*/Gemfile", __FILE__) do |file|
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
end
