Rails.application.config.middleware.use OmniAuth::Builder do
  provider :nctu,
           Rails.application.credentials[Rails.env.to_sym][:nctu][:client_id],
           Rails.application.credentials[Rails.env.to_sym][:nctu][:client_secret],
           scope: 'profile'
  provider :facebook,
           Rails.application.credentials[Rails.env.to_sym][:facebook][:client_id],
           Rails.application.credentials[Rails.env.to_sym][:facebook][:client_secret],
           scope: 'email'
  provider :google_oauth2,
           Rails.application.credentials[Rails.env.to_sym][:google][:client_id],
           Rails.application.credentials[Rails.env.to_sym][:google][:client_secret]
end
