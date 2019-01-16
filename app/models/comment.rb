class Comment < ApplicationRecord
  belongs_to :course
  belongs_to :user
  has_many :course_ratings, through: :user

  def serializable_hash(options = nil)
    options = options.try(:dup) || {}
    super({ **options, except: [:user_id, :course_id] }).tap do |result|
      result[:user] = user.serializable_hash(only: [:id, :name])
      result[:course] = course.serializable_hash(only: [:id, :name])
      result[:rating] = '000'
      course_ratings.each do |rating|
          result[:rating][rating.category] = rating.score.to_s
      end
    end
  end
end
