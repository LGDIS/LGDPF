# -*- coding:utf-8 -*-
Recaptcha.configure do |config|
  config.public_key  = API_KEY["recaptcha"]["public_key"]
  config.private_key = API_KEY["recaptcha"]["private_key"]
end