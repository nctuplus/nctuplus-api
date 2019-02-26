class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  validates :user_id, :comment_id, :content, presence: { message: '%{attribute} can not be empty' }
end
