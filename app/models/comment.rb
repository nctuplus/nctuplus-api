class Comment < ApplicationRecord
  belongs_to :course
  belongs_to :user
  has_one :permanent_course, through: :course
  has_many :teachers, through: :course
  has_many :course_ratings, through: :user
  has_many :replies, dependent: :delete_all

  validates :title, :content, presence: { message: '%{attribute} can not be empty' }
  validates :course_id, presence: { message: 'Must specify a course' }

  def self.latest
    rencent_10_comments = order('created_at DESC')
                          .limit(10)
                          .includes(:user, :course, :permanent_course, :teachers)
    rencent_10_replies = Reply.order('created_at DESC')
                              .limit(10)
                              .includes(:user, :comment)
    (rencent_10_comments + rencent_10_replies)
      .sort_by! { |record| record[:created_at] }
      .reverse!
      .slice(0, 10)
  end

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
      result[:reply] = replies.map { |reply| reply.serializable_hash(except: [:user_id, :comment_id]) }
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
      result[:reply] = replies.map { |reply| reply.serializable_hash(except: [:user_id, :comment_id]) }
    end
  end

  def serializable_hash_for_comment_latest_news
    {}.tap do |result|
      result[:id] = id
      result[:title] = title
      result[:course] = course.serializable_hash_for_comments
      result[:user] = { id: user_id, name: user.name } unless anonymity
      result[:anonymity] = anonymity
      result[:status] = 0
      result[:time] = created_at
      result[:reply] = nil
    end
  end

  # 建立該筆心得對應的評分紀錄
  def create_course_ratings(ratings = [0, 0, 0])
    # return false if the ratings is nil
    return false if ratings.nil?

    ratings_array = ratings.scan(/\d/).map(&:to_i)

    # Check if any rating is negative or larger than 5
    ratings_array.each do |rating|
      return false if rating > 5 || rating.negative?
    end
    ratings_array.each_with_index do |rating, index|
      user.course_ratings.create course: course, category: index, score: rating
    end
    true
  end

  # 更新該筆心得對應的評分紀錄
  def update_course_ratings(ratings = [0, 0, 0])
    return if ratings.nil?

    previous_rating = course_ratings.order(:category).pluck(:score)
    ratings_array = ratings.scan(/\d/).map(&:to_i)

    # return if the ratings remain unchanged
    return if previous_rating.eql?(ratings_array)

    # Delete old ratings records
    course_ratings.delete_all
    # Create updated rating records
    create_course_ratings(ratings)
  end
end
