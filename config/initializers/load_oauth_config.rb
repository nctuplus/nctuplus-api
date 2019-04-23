NCTU_OAUTH_CONFIG = YAML.safe_load(File.read("#{Rails.root}/config/nctu.yml")).symbolize_keys
FACEBOOK_OAUTH_CONFIG = YAML.safe_load(File.read("#{Rails.root}/config/facebook.yml")).symbolize_keys
GOOGLE_OAUTH_CONFIG = YAML.safe_load(File.read("#{Rails.root}/config/google.yml")).symbolize_keys
