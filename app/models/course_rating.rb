class CourseRating < ApplicationRecord
  belongs_to :user
  belongs_to :course

  def serializable_hash(option = nil)
	options = options.try(:dup) || {}
	super({ **options }).tap do |result|
	  result[:user_id] = user_id
	  result[:course_id] = course_id
	  result[:category] = category
	  result[:score] = score
	end
  end
  
end
