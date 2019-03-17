class Course < ApplicationRecord
  belongs_to :semester
  belongs_to :last_edit_user, class_name: :User, optional: true
  belongs_to :permanent_course
  belongs_to :department
  has_many :teachers_courses
  has_many :teachers, through: :teachers_courses
  has_many :users_courses
  has_many :users, through: :users_courses
  has_many :books_courses
  has_many :books, through: :books_courses
  has_many :ratings, foreign_key: :course_id, class_name: :CourseRating
  has_many :comments, foreign_key: :course_id
  has_many :past_exams
  has_many :scores
  delegate :name, to: :permanent_course, prefix: :permanent_course
  enum time_slot_code: %I[M N A B C D X E F G H Y I J k L]

  # 現在 DB 裡用 12bytes(96bit) 的 binary 來保存課程時段
  # (16 的時段 * 每週 6 天 = 96(bit)),
  # 所以在傳給前端時我們需要轉換成比較容易讀得懂的形式
  def convert_time_slots
    # 96bits
    # 切成 6 個 2bytes 的 string
    # 將每個 2bytes string 轉成長度 16 的 bitmask: [0, 1, 1 ...., 0]
    # 將每個 bitmask 轉成時段對應的英文字母陣列: ['A', 'B', 'M']
    # 將字母陣列跟 index 結合: [0, ['A, 'B', 'M']]
    # 將前面作成的 array 轉成 hash
    time_slots
      .chars.each_slice(2)
      .map { |data| data.join('').unpack1('S') }
      .map do |data|
        16.times
          .select { |i| (data & (1 << i)).positive? }
          .map { |i| self.class.time_slot_codes.key(i) }
      end
      .map.with_index { |data, index| [index, data] }
      .each_with_object({}) do |entry, result|
        key = entry[0] + 1
        value = entry[1]
        result[key] = value unless value.empty?
        result
      end
  end

  # 計算三向度的平均評分
  def average_ratings
    [].tap do |average_ratings_array|
      [0, 1, 2].each do |category_number|
        average_rating = ratings.where(category: category_number).average(:score).to_f
        average_ratings_array << (average_rating.nil? ? 0 : average_rating)
      end
    end
  end

  # 重載 json serializer
  def serializable_hash(options = nil)
    options = options.try(:dup) || {}

    onlys = %I[id code credit grade classroom registration_count registration_limit created_at updated_at]
    super({ **options, only: onlys }).tap do |result|
      result[:semester] = semester.serializable_hash_for_course
      result[:department] = department.serializable_hash_for_course
      result[:teachers] = teachers.map(&:serializable_hash_for_course)
      result[:time_slots] = convert_time_slots
      result[:ratings] = average_ratings
      result[:permanent_course] = permanent_course.serializable_hash_for_course
    end
  end

  def serializable_hash_for_single_course
    {}.tap do |result|
      result[:href] = 'https://timetable.nctu.edu.tw/?r=main/'\
        "crsoutline&Acy=#{semester.year}&Sem=#{semester.term}&CrsNo=#{code}&lang=zh-tw"
      result[:rating] = average_ratings
      result[:created_at] = created_at
      result[:updated_at] = updated_at
      result[:similar_courses] = recommend_courses
      result[:course_infos] = past_course_infos
      result[:permanent_course] = permanent_course.serializable_hash_for_course
    end
  end

  def serializable_hash_for_books
    {}.tap do |result|
      result[:id] = id
      result[:name] = permanent_course_name
      result[:teachers] = teachers.map(&:name)
    end
  end

  def serializable_hash_for_comments
    {}.tap do |result|
      result[:id] = id
      result[:name] = permanent_course_name
      result[:teachers] = teachers.map(&:name)
    end
  end

  def serializable_hash_for_applicable_course
    {}.tap do |result|
      result[:id] = id
      result[:semester] = semester.serializable_hash_for_course
      result[:teachers] = teachers.map(&:serializable_hash_for_course)
      result[:permanent_course] = { id: permanent_course.id, name: permanent_course_name }
    end
  end

  # 找出此堂課的歷年開課紀錄(限定同開課老師)
  def related_courses
    courses = Course.includes(:teachers)
                    .where(permanent_course_id: permanent_course_id)
    [].tap do |result|
      courses.each do |c|
        result.push(c) if (c.teacher_ids - teacher_ids).empty?
      end
    end
  end

  # 找出推薦的課程(利用分數資料)
  def recommend_courses
    courses = Score.where(user_id: user_ids)
                   .where.not(course_id: id)
                   .group(:course_id)
                   .order('count_all desc')
                   .limit(5)
                   .count.keys
    courses.map do |course_id|
      Hash[Course.find(course_id).permanent_course_name, course_id]
    end
  end

  # 將related_courses的結果序列化
  def past_course_infos
    [].tap do |course_infos|
      related_courses.each do |course|
        course_infos << {
          id: course.id,
          semester: course.semester.serializable_hash_for_course,
          department: course.department.serializable_hash_for_course,
          code: course.code,
          requirement_type: course.requirement_type,
          registration_count: course.registration_count,
          registration_limit: course.registration_limit,
          time_slots: course.convert_time_slots,
          classroom: course.classroom,
          grade: course.grade,
          credit: course.credit,
          teachers: course.teachers.map(&:serializable_hash_for_course),
          remarks: course.remarks
        }
      end
    end
  end
end
