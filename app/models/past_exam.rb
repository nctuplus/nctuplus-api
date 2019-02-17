class PastExam < ApplicationRecord
  belongs_to :course
  belongs_to :uploader, class_name: :User
  delegate :name, to: :uploader, prefix: true
  mount_base64_uploader :file, PastExamUploader
  def serializable_hash_for_course
    {}.tap do |result|
      result[:id] = id
      result[:description] = description
      result[:download_count] = download_count
      result[:file] = { url: file_url }
      result[:uploader_id] = uploader.id
      result[:created_at] = created_at
      result[:updated_at] = updated_at
    end
  end

  def serializable_hash(options = nil)
    options = options.try(:dup) || {}
    excepts = %I[uploader_id course_id created_at updated_at]
    super({ **options, except: excepts }).tap do |result|
      result[:uploader] = uploader_name
      result[:course] = {
        name: course.permanent_course.name,
        semester: course.semester.serializable_hash_for_past_exam,
        teacher: course.teachers.try do |course_teachers|
          course_teachers.map(&:name)
        end
      }
    end
  end
end
