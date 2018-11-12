class CourseRating < ApplicationRecord
  belongs_to :user
  belongs_to :course

  def serializable_hash(option = nil)
	options = options.try(:dup) || {}
	super({ **options }).tap do |result|
	  result[:category] = category
	  result[:score] = score
	end
  end

end
