class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 15
    filters = Comment.includes(:course, :user).ransack
    @comments = filters.result(distinct: true).page(page).per(per_page)

    render json: {
      current_page: page,
      total_pages: @comments.total_pages,
      total_count: @comments.total_count,
      data: @comments
    }
  end

  def show
    render json: @comment
  end

  # POST /comments
  def create
    @comment = current_user.comments.build(comment_params)

    if @comment.save
      render json: @comment, status: :created, location: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH /comments/:id
  def update
    if @comment.user_id != current_user.id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    elsif @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
    @comment.course_ratings.each do |rating|
      rating.score = param[:rating][rating.category].to_i
    end
  end

  def destroy
    if @comment.user_id != current_user.id
      render json: @comment.errors, status: :unauthorized
    else
      @comment.destroy
    end
  end

  private

  def set_comment
    @comment = Comment.includes(:course, :user, :course_ratings).find(params[:id])
  end

  def comment_params
    params.fetch(:comment, {}).permit(:title, :content, :anonymity, :course_id)
  end
end
