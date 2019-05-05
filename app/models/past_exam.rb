class PastExam < ApplicationRecord
  belongs_to :course
  has_one :permanent_course, through: :course
  has_many :teachers, through: :course
  belongs_to :uploader, class_name: :User
  delegate :name, to: :uploader, prefix: true
  mount_base64_uploader :file, PastExamUploader
  def serializable_hash_for_course
    {}.tap do |result|
      result[:id] = id
      result[:description] = description
      result[:download_count] = download_count
      result[:file] = { url: file_url }
      result[:uploader] = {
        id: uploader_id,
        name: uploader_name
      }
      result[:anonymity] = anonymity
      result[:course] = {
        name: course.permanent_course.name,
        semester: course.semester.serializable_hash_for_past_exam,
        teacher: course.teachers.map(&:name)
      }
    end
  end

  def serializable_hash(options = nil)
    options = options.try(:dup) || {}
    excepts = %I[uploader_id course_id]
    super({ **options, except: excepts }).tap do |result|
      result[:uploader] = { id: uploader.id, name: uploader_name }
      result[:course] = {
        name: course.permanent_course.name,
        semester: course.semester.serializable_hash_for_past_exam,
        teacher: course.teachers.map(&:name)
      }
    end
  end
end
