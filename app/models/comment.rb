class Comment < ApplicationRecord
  belongs_to :course
  has_one :permanent_course, through: :course
  has_many :teachers, through: :course
  belongs_to :user
  has_many :course_ratings, through: :user

  # 重載course_ratings方法
  # 使其只返回該筆心得所對應到的評分紀錄
  def course_ratings
    super.where(course_id: course_id, user_id: user_id)
  end

  def serializable_hash(options = nil)
    options = options.try(:dup) || {}
    super({ **options, except: [:user_id, :course_id] }).tap do |result|
      result[:course] = course.serializable_hash_for_comments
      result[:user] = { 'id': user_id, 'name': user.name }
      result[:rating] = '000'
      course_ratings.each do |rating|
        result[:rating][rating.category] = rating.score.to_s
      end
    end
  end

  def serializable_hash_for_course
    {}.tap do |result|
      result[:id] = id
      result[:title] = title
      result[:content] = content
      result[:rating] = '000'
      course_ratings.each do |rating|
        result[:rating][rating.category] = rating.score.to_s
      end
      result[:course] = course.serializable_hash_for_comments
      result[:user] = { id: user_id, name: user.name }
      result[:anonymity] = anonymity
    end
  end

  # 建立該筆心得對應的評分紀錄
  def create_course_ratings(ratings = [0, 0, 0])
    ratings.each do |rating|
      return false if rating > 5 || rating.negative?
    end
    ratings.each_with_index do |rating, index|
      user.course_ratings.create course: course, category: index, score: rating
    end
    true
  end

  # 更新該筆心得對應的評分紀錄
  def update_course_ratings(ratings = [0, 0, 0])
    previous_rating = course_ratings.order(:category).pluck(:score)
    return if previous_rating.eql?(ratings) || ratings.nil?

    # Delete old ratings records
    course_ratings.delete_all
    # Create updated rating records
    create_course_ratings(ratings)
  end
end
