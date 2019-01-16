class PermanentCourse < ApplicationRecord
  def serializable_hash_for_course 
    {}.tap do |result|
        result[:id] = id
        result[:code] = code
        result[:name] = name
    end
  end
end
