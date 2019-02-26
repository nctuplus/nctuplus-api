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

  def serializable_hash_for_comment_latest_news
    comment.serializable_hash_for_comment_latest_news.tap do |result|
      result[:status] = 1
      result[:time] = created_at
      result[:reply] = serializable_hash(only: [:anonymity, :id])
    end
  end
end
