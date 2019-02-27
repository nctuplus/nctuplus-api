class ReplyController < ApplicationController
  before_action :set_reply, except: [:create]
  before_action :authenticate_user!

  def create
    @reply = current_user.replies.build(reply_params.merge(comment_id: params[:comment_id]))
    @reply.anonymity = false if params[:anonymity].is_a? FalseClass

    if !Comment.exists?(id: params[:comment_id])
      render json: { 'error': 'associated comment does not exist' }, status: :unprocessable_entity
    elsif @reply.save
      render status: :created
    else
      render json: @reply.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.id != @reply.user_id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    else
      @reply.destroy
    end
  end

  private

  # Callback function to set the requested reply by id in advance
  def set_reply
    @reply = Reply.find(params[:id] || params[:reply_id])
  end

  def reply_params
    params.fetch(:reply, {})
          .permit(:content)
  end
end
