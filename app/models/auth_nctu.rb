class AuthNctu < AuthBase
  # Create a oauth2 record from the data got from NCTU Oauth
  def self.create_record_from_oauth2(user_info)
    AuthNctu.find_or_initialize_by(student_id: user_info[:uid]).tap do |record|
      record.student_id = user_info[:uid]
      record.name = user_info[:info][:name]
      record.email = user_info[:info][:email]
      record.save
    end
  end

  def find_or_initialize_user_by_uid_provider(uid:, provider: 'nctu')
    super
  end
end
