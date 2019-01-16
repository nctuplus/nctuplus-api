class BulletinsController < ApplicationController
  before_action :set_bulletin, only: [:show, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /bulletins
  def index
    @bulletins = Bulletin.all

    render json: @bulletins
  end

  # GET /bulletins/1
  def show
    render json: @bulletin
  end

  # POST /bulletins
  def create
    @bulletin = current_user.bulletins.build(bulletin_params)

    if @bulletin.save
      render json: @bulletin, status: :created
    else
      render json: @bulletin.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bulletins/1
  def update
    if current_user.id != @bulletin.author_id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    elsif @bulletin.update(bulletin_params)
      render json: @bulletin
    else
      render json: @bulletin.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bulletins/1
  def destroy
    if current_user.id != @bulletin.author_id
      render json: { 'error': 'user does not match' }, status: :unauthorized
    else
      @bulletin.destroy
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bulletin
    @bulletin = Bulletin.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def bulletin_params
    params.fetch(:bulletin, {})
          .permit(
            :title, :category,
            :begin_time, :end_time, :author_id
          )
  end
end
