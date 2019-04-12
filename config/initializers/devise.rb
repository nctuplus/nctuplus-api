Devise.setup do |config|
    config.mailer_sender = "support@myapp.com"
    require 'devise/orm/active_record'
    config.navigational_formats = [:json]
end
