class AuthBase < ApplicationRecord
  # Disable single-table inheritance(STI)
  self.abstract_class = true
  belongs_to :user

  # Find the associated user record by provider and uid,
  # or create a new user record if none of user record can be found
  def find_or_initialize_user_by_uid_provider(uid:, provider:)
    # Return the user if it already exists
    return user unless user.nil?

    # Create a new user record if it does not exist and the return the record
    new_user_record = User.new(name: name, email: email, provider: provider, uid: uid)
    if new_user_record.save
      # Bind the user on this auth record
      update(user: new_user_record)
    else
      new_user_record = nil
    end
    new_user_record
  end

  # Perform data transfer from old user to new user based on new_user_id parameter
  def original_user_data_transferring(new_user_id:)
    # Return if the user signs in N+ by this platorm first time since there won't be associated user record
    return if user.nil?

    original_user_id = user.id
    original_user = User.find(original_user_id)
    # Key is the association name, value is the foreign key name
    # { books: 'user_id', past_exams: 'uploader_id', ... }
    associations_hash = {}
    User.reflect_on_all_associations.each do |association|
      # Ignore association created by through(has_many through),
      # since those associations object caused by has_many through does not have that foreign_key
      # TODO: Add procedure to transfer data caused by belongs_to assoication
      next if association.through_reflection? || association.belongs_to?

      associations_hash[association.name.to_sym] = association.foreign_key
    end

    # Update the foreign key fieid of those associated records
    associations_hash.each do |key, value|
      update_filter_rule_hash = {}.tap { |filter| filter[value.to_sym] = original_user_id }
      update_attributes_hash = {}.tap { |attr| attr[value.to_sym] = new_user_id }
      original_user.public_send(key).try(:where, update_filter_rule_hash).try(:update_all, update_attributes_hash)
    end

    # Deal with special associations
    original_user.events.where(user_id: original_user_id).update_all(user_id: new_user_id)

    # Destroy original user record
    original_user.destroy
  end
end
