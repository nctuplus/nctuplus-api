class PastExam < ApplicationRecord
  belongs_to :course
  belongs_to :uploader, class_name: :User
  mount_base64_uploader :file, PastExamUploader
  def serializable_hash_for_course
    result = serializable_hash(:only => %I(id description download_count file 
        created_at updated_at))
    result[:uploader_id] = result[:uploader][:id]
    result[:course_id] = result[:course][:id]
    result[:created_at] = result[:created_at]
    result[:updated_at] = result[:updated_at]
    result.except!(:uploader, :course)
  end


  def serializable_hash(options = nil)
    options = options.try(:dup) || {}
    super({ **options, except: [:uploader_id, :course_id] }).tap do |result|
      result[:uploader] = uploader
      result[:course] = course
      result[:created_at] = created_at
      result[:updated_at] = updated_at
    end
  end
end
