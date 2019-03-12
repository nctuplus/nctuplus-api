class PastExamsController < ApplicationController
  before_action :set_past_exam, only: [:show, :update, :destroy]
  before_action :authenticate_user!, except: [:index]

  # GET /past_exams
  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 25
    filters = PastExam.ransack(params[:q])

    @past_exams = filters
                  .result(distinct: true)
                  .includes({ course: [:semester, :teachers, :permanent_course] }, :uploader)
                  .page(page).per(per_page)

    render json: {
      current_page: page,
      total_pages: @past_exams.total_pages,
      total_count: @past_exams.total_count,
      data: @past_exams
    }
  end

  # POST /past_exams
  def create
    @past_exam = current_user.past_exams.build(past_exam_params.merge(course_id: params[:course].try(:[], :id)))

    if @past_exam.save
      render status: :created, location: @past_exam
    else
      render json: @past_exam.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /past_exams/1
  def update
    if current_user.id != @past_exam.uploader_id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    elsif @past_exam.update(past_exam_params)
      render json: @past_exam, location: @past_exam.file_url
    else
      render json: @past_exam.errors, status: :unprocessable_entity
    end
  end

  # DELETE /past_exams/1
  def destroy
    if current_user.id != @past_exam.uploader_id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    else
      @past_exam.destroy
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_past_exam
    @past_exam = PastExam.includes(:course, :uploader).find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def past_exam_params
    params.fetch(:past_exam, {})
          .permit(:description, :file, :anonymity)
  end
end
