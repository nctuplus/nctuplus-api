class Slogan < ApplicationRecord
  belongs_to :author, class_name: :User, foreign_key: :author_id, inverse_of: :slogans
  validates :display,
            inclusion: { in: [true, false], message: 'Must be boolean value' }

  # 重載serializable_hash
  def serializable_hash(options = nil)
    options = options.try(:dup) || {}

    super({ **options, except: :author_id }).tap do |result|
      result[:author] = { user_id: author_id, name: author.name }
    end
  end
end
