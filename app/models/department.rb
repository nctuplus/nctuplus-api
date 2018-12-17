class Department < ApplicationRecord
  belongs_to :college
  has_many :courses
  def serializable_hash_for_course
    {}.tap do |result|
        result[:id] = id
        result[:name] = name
    end
  end
end
