NCTU_OAUTH_CONFIG = YAML.safe_load(File.read("#{Rails.root}/config/nctu.yml")).try(:symbolize_keys)
FACEBOOK_OAUTH_CONFIG = YAML.safe_load(File.read("#{Rails.root}/config/facebook.yml")).try(:symbolize_keys)
GOOGLE_OAUTH_CONFIG = YAML.safe_load(File.read("#{Rails.root}/config/google.yml")).try(:symbolize_keys)
