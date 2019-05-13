Rails.application.config.middleware.use OmniAuth::Builder do
  provider :nctu,
           NCTU_OAUTH_CONFIG[:client_id],
           NCTU_OAUTH_CONFIG[:client_secret],
           scope: 'profile',
           redirect_uri: 'https://{HOSTNAME}/auth/nctu/callback'
  provider :facebook,
           FACEBOOK_OAUTH_CONFIG[:client_id],
           FACEBOOK_OAUTH_CONFIG[:client_secret],
           scope: 'email',
           callback_url: 'https://{HOSTNAME}/auth/facebook/callback'
  provider :google_oauth2,
           GOOGLE_OAUTH_CONFIG[:client_id],
           GOOGLE_OAUTH_CONFIG[:client_secret],
           redirect_uri: 'https://{HOSTNAME}/auth/google_oauth2/callback'
end
