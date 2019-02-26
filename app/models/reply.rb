class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  validates :user_id, :comment_id, :content, presence: { message: '%{attribute} can not be empty' }

  def serializable_hash(options = nil)
    options = options.try(:dup) || {}
    super({ **options }).tap do |result|
      unless anonymity
        result[:user] = {
          id: user.id,
          name: user.name
        }
      end
    end
  end
end
