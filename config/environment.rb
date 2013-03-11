# Load the rails application
require File.expand_path('../application', __FILE__)

# Load original settings
SETTINGS = YAML.load_file("#{Rails.root}/config/settings.yml")


# Initialize the rails application
Lgdpf::Application.initialize!
