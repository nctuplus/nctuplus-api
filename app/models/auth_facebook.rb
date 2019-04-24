class AuthFacebook < AuthBase
  # Create a oauth2 record from the data got from Facebook
  def self.create_record_from_oauth2(user_info)
    find_or_initialize_by(uid: user_info[:uid]).tap do |record|
      record.uid = user_info[:uid]
      record.name = user_info[:info][:name]
      record.email = user_info[:info][:email]
      record.image_url = user_info[:info][:image]
      record.save
    end
  end

  def find_or_initialize_user_by_uid_provider(uid:, provider: 'facebook')
    super
  end
end
