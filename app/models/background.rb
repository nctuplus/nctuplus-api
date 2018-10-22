class Background < ApplicationRecord
  belongs_to :author, class_name: :User, foreign_key: :author_id

  mount_base64_uploader :cover_image, EventCoverUploader

  def serializable_hash(options = nil)
    options = options.try(:dup) || {}
    super({ **options, except: [:author_id] }).tap do |result|
      result[:author] = author.serializable_hash(only: [:id, :name])
    end
  end
end
