Rails.application.config.middleware.use OmniAuth::Builder do
  provider :nctu,
           NCTU_OAUTH_CONFIG[:client_id],
           NCTU_OAUTH_CONFIG[:client_secret],
           scope: 'profile'
  provider :facebook,
           FACEBOOK_OAUTH_CONFIG[:client_id],
           FACEBOOK_OAUTH_CONFIG[:client_secret],
           scope: 'email'
  provider :google_oauth2,
           GOOGLE_OAUTH_CONFIG[:client_id],
           GOOGLE_OAUTH_CONFIG[:client_secret]
end
