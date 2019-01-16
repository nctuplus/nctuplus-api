class Bulletin < ApplicationRecord
  belongs_to :author, class_name: :User, foreign_key: :author_id, inverse_of: :bulletins

  validates :title, presence: { message: 'titile can not be empty' }
  validates :category, inclusion: { in: [0, 1], message: 'category must be 0 or 1' }

  def serializable_hash(options = nil)
    options = options.try(:dup) || {}

    super({ **options, expect: :author_id }).tap do |result|
      result[:author] = { user_id: author_id, name: author.name }
    end
  end
end
