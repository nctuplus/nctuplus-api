class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :update, :destroy]
  before_action :authenticate_user!, only: [:rating, :favorite, :remove_favorite, :applicable_courses]

  # GET /courses
  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 25
    filters = Course
              .includes(:semester, :last_edit_user, :permanent_course, :teachers, :ratings, :department)
              .ransack(params[:q])

    @courses = filters.result(distnct: true).page(page).per(per_page)

    render json: {
      current_page: page,
      total_pages: @courses.total_pages,
      total_count: @courses.total_count,
      data: @courses
    }
  end

  # GET /courses/1
  def show
    render json: @course.serializable_hash_for_single_course
  end

  # @todo: 當資料有改動的時候更新 last_edit_user_id
  # PATCH/PUT /courses/1
  def update
    if @course.update(course_params)
      render json: @course
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  # 更新評分的 action，若已經評分過該課程的該面向則更新分數
  # POST /courses/:id/rating
  def rating
    rating_params = params.permit(:category, :score, :course_id)
    # 確認先前是否已經評分過
    previous_ratings = current_user.course_ratings.select do |rating|
      rating.category == rating_params[:category].to_i &&
      rating.course_id == rating_params[:course_id].to_i
    end
    previous_rating = previous_ratings.first

    # 若有，更新分數
    if previous_rating.present?
      course_rating = previous_rating
      course_rating.update(score: rating_params[:score])
    # 若沒有，新增一個 CoureseRatingModel，並加進去 user 和 course 的評分中
    else
      course_rating = CourseRating.new(rating_params)
      current_user.course_ratings << course_rating
      current_user.save
    end

    if course_rating.save
      render json: course_rating, status: :created
    else
      render json: course_rating.errors, status: :unprocessable_entity
    end
  end

  # POST /courses/:id/favorite
  def favorite
    course_id = params[:course_id]
    UsersCourse
      .where(user_id: current_user.id, course_id: course_id)
      .first_or_create
    render json: {}, status: :created
  end

  # DELETE /courses/:id/favorite
  def remove_favorite
    course_id = params[:course_id]
    UsersCourse.where(user_id: current_user.id, course_id: course_id).destroy_all
    render json: {}, status: :no_content
  end

  # GET /courses/:id/past_exams
  def past_exams
    course_id = params[:course_id]
    past_exams = PastExam.where(course_id: course_id)
                         .includes(:uploader)
    render json: past_exams.map(&:serializable_hash_for_course)
  end

  # GET /courses/:id/comments
  def show_comments
    course_id = params[:course_id]
    comments = Comment.where(course_id: course_id)
                      .includes(:user, :teachers, :course_ratings)
    render json: comments.map(&:serializable_hash_for_course)
  end

  # POST /courses/applicable_courses
  def applicable_courses
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 25
    filters = Course
              .includes(:semester, :permanent_course, :teachers)
              .ransack(semester_term_eq: params[:term],
                       semester_year_eq: params[:year],
                       permanent_course_name_cont: params[:keyword])
    @courses = filters.result(distnct: true).page(page).per(per_page)

    render json: {
      current_page: page,
      total_pages: @courses.total_pages,
      total_count: @courses.total_count,
      data: @courses.map(&:serializable_hash_for_applicable_course)
    }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course
              .includes(:semester, :last_edit_user, :permanent_course, :teachers, :ratings)
              .find(params[:id] || params[:course_id])
  end

  # Only allow a trusted parameter "white list" through.
  def course_params
    params.fetch(:course, {})
          .permit(:assignment_record, :exam_record, :rollcall_frequency)
  end
end
