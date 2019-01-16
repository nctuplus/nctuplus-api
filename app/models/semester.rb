class Semester < ApplicationRecord
  has_many :courses
  def serializable_hash_for_course
    {}.tap do |result|
        result[:year] = year 
        result[:term] = term
    end
  end
end
