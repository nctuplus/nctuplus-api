Rails.application.config.middleware.use OmniAuth::Builder do
  provider :nctu,
           Rails.application.credentials[Rails.env.to_sym][:nctu][:client_id],
           Rails.application.credentials[Rails.env.to_sym][:nctu][:client_secret],
           scope: 'profile',
           redirect_uri: 'https://plus.nctu.edu.tw/auth/nctu/callback'
  provider :facebook,
           Rails.application.credentials[Rails.env.to_sym][:facebook][:client_id],
           Rails.application.credentials[Rails.env.to_sym][:facebook][:client_secret],
           scope: 'email',
           callback_url: 'https://plus.nctu.edu.tw/auth/facebook/callback'
  provider :google_oauth2,
           Rails.application.credentials[Rails.env.to_sym][:google][:client_id],
           Rails.application.credentials[Rails.env.to_sym][:google][:client_secret]
           redirect_uri: 'https://plus.nctu.edu.tw/auth/google_oauth2/callback'
end
