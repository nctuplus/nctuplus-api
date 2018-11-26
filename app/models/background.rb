class Background < ApplicationRecord
  belongs_to :author, class_name: :User, foreign_key: :author_id

  mount_base64_uploader :cover_image, EventCoverUploader
end
