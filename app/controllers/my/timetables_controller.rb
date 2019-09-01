class My::TimetablesController < ApplicationController
  before_action :set_timetable, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  # GET /my/timetables
  def index
    result = {
      data: current_user.timetables
                        .select { |table| table.courses.first.semester.year == params[:year] }
                        .select { |table| table.courses.first.semester.term == params[:term] }
    }
    result[:data] = result[:data].first.courses.map(&:serializable_hash_for_timetable) unless result[:data].empty?
    render json: result
  end

  # PUT /my/timetables
  def create
    if params[:type] == 'add'
      add_course
    elsif params[:type] == 'delete'
      delete_course
    end
    render json: {
      updated_at: current_user.timetables.last.updated_at
    }
  end

  def add_course
    c = Course.where(code: params[:code]).last
    t = current_user.timetables
    if t.empty? ||
      (!t.last.courses.empty? && t.last.courses.last.semester != c.semester)
      t.create
    end
    t.last.courses.push(c)
  end

  def delete_course
    current_user.timetables.last.courses.delete(Course.where(code: params[:code]).last)
  end

  # PATCH/PUT /my/timetables/1
  # 如果 current_user 不是此課表擁有者則回傳 403 forbidden
  def update
    return render json: {}, status: :forbidden unless @timetable.user == current_user

    type = params[:type].to_sym
    course_id = params[:course_id].try(:to_i)
    if type == :add
      TimetablesCourse.where(timetable_id: @timetable.id, course_id: course_id).first_or_create
    elsif type == :delete
      TimetablesCourse.where(timetable_id: @timetable.id, course_id: course_id).destroy_all
    end

    @timetable.reload

    if @timetable
      render json: @timetable, include: [:courses]
    else
      render json: @timetable.errors, status: :unprocessable_entity
    end
  end

  # DELETE /my/timetables/1
  def destroy
    @timetable.destroy if @timetable.user == current_user
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_timetable
    @timetable = Timetable.includes(:courses).find(params[:id])
  end
end
