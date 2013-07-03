source 'https://rubygems.org'

# Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. 
# # It encourages beautiful code by favoring convention over configuration.
gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Pg is the Ruby interface to the PostgreSQL RDBMS.
# It works with PostgreSQL 8.3 and later.
gem 'pg', '0.15.1'

# ActiveRecord extension to get more from PostgreSQL.
gem 'pg_power', '1.6.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '0.11.4', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

# This gem provides jQuery and the jQuery-ujs driver for your Rails 3 application.
gem 'jquery-rails', '3.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server. LGDPF default Rack HTTP Server.
gem 'unicorn', '4.6.3'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# CarrierWave is Upload files in your Ruby applications, map them
# to a range of ORMs, store them on different backends.
gem 'carrierwave', '0.8.0'

# If you're uploading images by CarrierWave, you'll probably want to
# manipulate them in some way, you might want to create thumbnail images
# for example. CarrierWave comes with a small library to make manipulating
# images with RMagick easier.
gem 'rmagick', '~> 2.12.2'

# recaptcha adds helpers for the reCAPTCHA API.
gem 'recaptcha', '0.3.5', :require => 'recaptcha/rails'

# Dalli is a high performance pure Ruby client for accessing memcached servers.
gem 'dalli', '2.6.4'

# jpmobile is Rails plugin for Japanese mobile-phones.
gem 'jpmobile', '4.0.0'
gem 'jpmobile-terminfo', '0.0.3'

# Devise is Flexible authentication solution for Rails with Warden.
gem 'devise', '2.2.4'

# Devise extension to allow authentication via LDAP.
gem 'devise_ldap_authenticatable', '0.7.0'

# acts_as_paranoid is Active Record (~>3.2) plugin which allows you to
# hide and restore records without actually deleting them.
gem 'acts_as_paranoid', '0.4.2'

# A Scope & Engine based, clean, powerful, customizable and sophisticated
# paginator for modern web app frameworks and ORMs.
gem 'kaminari', '0.14.1'

group :test do
  # Rspec-2 meta-gem that depends on the other components.
  gem 'rspec', '2.13.0'
  gem 'rspec-html-matchers', '0.4.1'
  gem 'mime-types', '1.23'

  # factory_girl is a fixtures replacement with a straightforward
  # definition syntax, support for multiple build strategies (saved
  # instances, unsaved instances, attribute hashes, and stubbed objects),
  # and support for multiple factories for the same class (user,
  # admin_user, and so on), including factory inheritance.
  gem 'factory_girl_rails', '4.2.1'
end

platforms :mri_20 do
  # Iconv is a wrapper class for the UNIX 95 iconv() function family,
  # which translates string between various encoding systems.
  gem 'iconv', '1.0.2'
end

# Rake is a Make-like program implemented in Ruby. 
# Tasks and dependencies arespecified in standard Ruby syntax.
gem 'rake', '10.0.4' 

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
