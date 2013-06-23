# -*- coding: utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

# Load original settings
SETTINGS = YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]
API_KEY  = YAML.load_file("#{Rails.root}/config/api_key.yml")

# 動作種別の切り替え
require File.expand_path('../../lib/acts/acts_as_mode_switchable', __FILE__)
# 動作種別
RUN_MODE = {
  normal:   0,  # 通常モード
  training: 1,  # 災害訓練モード
  test:     2   # 通信試験モード
}.freeze
# 現在の動作種別
CURRENT_RUN_MODE = SETTINGS["run_mode"]
CURRENT_IS_NORMAL_MODE = (RUN_MODE.invert[CURRENT_RUN_MODE] == :normal)

# Initialize the rails application
Lgdpf::Application.initialize!
