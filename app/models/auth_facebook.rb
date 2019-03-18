class AuthFacebook < ApplicationRecord
  belongs_to :user

  def self.create_record_from_oauth2(user_info)
    find_or_initialize_by(uid: user_info[:uid]).tap do |record|
      record.uid = user_info[:uid]
      record.name = user_info[:info][:name]
      record.email = user_info[:info][:email]
      record.image_url = user_info[:info][:image]
      record.save
    end
  end

  def find_or_initialize_user_by_uid(uid)
    # Return the user if it already exists
    return user unless user.nil?

    # Create the user if it does not exist and then return it
    new_user_record = User.new(name: name, email: email, provider: 'facebook', uid: uid)
    if new_user_record.save
      update(user: new_user_record)
    else
      new_user_record = nil
    end
    new_user_record
  end
end
