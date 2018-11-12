class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :authenticate_user, except: [:index, :show]
  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 15
    filters = Comment.includes(:course, :user).ransack()
    @comments = filters.result(distinct: true).page(page).per(per_page)

    render json: {
      current_page: page,
      total_pages: @comments.total_pages,
      total_count: @comments.total_count,
      data: @comments
    }
  end
private
  def set_comment
    @cmment = Comment.includes(:courses, :user, :course_ratings).find(params[:id])
  end
  def comment_params
    params.fetch(:comment, {}).permit(:title, :content)
  end
end
