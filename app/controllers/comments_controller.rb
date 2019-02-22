class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /comments
  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 25
    filters = Comment.includes(:course, :user, :course_ratings,
                               :permanent_course, :teachers).ransack(params[:q])
    @comments = filters.result(distinct: true).page(page).per(per_page)

    render json: {
      current_page: page,
      total_pages: @comments.total_pages,
      total_count: @comments.total_count,
      data: @comments
    }
  end

  # GET /comments/:id
  def show
    render json: @comment
  end

  # POST /comments
  def create
    if !Comment.exists?(user_id: current_user.id, course_id: params[:course_id])
      @comment = current_user.comments.build(comment_params)
      if @comment.valid?
        if @comment.create_course_ratings(params[:rating].scan(/\d/).map(&:to_i))
          @comment.save
          render json: @comment, status: :created, location: @comment
        else
          render json: { 'error': 'rating out of range' }, status: :unprocessable_entity
        end
      else
        render json: @comment.errors, status: :unprocessable_entity
      end
    else
      render json: { 'message': '心得已存在' }, status: :ok
    end
  end

  # PATCH /comments/:id
  def update
    if @comment.user_id != current_user.id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    elsif @comment.update(comment_params)
      @comment.update_course_ratings(params[:rating].scan(/\d/).map(&:to_i))
      render json: @comment, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/:id
  def destroy
    if @comment.user_id != current_user.id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    else
      @comment.course_ratings.destroy_all
      @comment.destroy
    end
  end

  private

  def set_comment
    @comment = Comment.includes(:course, :user, :course_ratings, :permanent_course, :teachers).find(params[:id])
  end

  def comment_params
    params.fetch(:comment, {}).permit(:title, :content, :anonymity, :course_id)
  end
end
