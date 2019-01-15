class SlogansController < ApplicationController
  before_action :set_slogan, only: [:show, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /slogans
  def index
    @slogans = Slogan.all

    render json: @slogans
  end

  # GET /slogans/1
  def show
    render json: @slogan
  end

  # POST /slogans
  def create
    @slogan = current_user.slogans.build(slogan_params)

    if @slogan.save
      render json: @slogan, status: :created
    else
      render json: @slogan.errors, status: :unprocessable_entity
    end
  end

  # PATCH /slogans/1
  def update
    if current_user.id != @slogan.author_id
      render json: { "error": "user does not match" }, status: :unauthorized
    elsif @slogan.update(slogan_params)
      render json: @slogan
    else
      render json: @slogan.errors, status: :unprocessable_entity
    end
  end

  # DELETE /slogans/1
  def destroy
    if current_user.id != @slogan.author_id
      render json: { "error": "user does not match" }, status: :unauthorized
    else
      @slogan.destroy
    end
  end

  private

  def set_slogan
    @slogan = Slogan.find(params[:id])
  end

  def slogan_params
    params.fetch(:slogan, {})
          .permit(
            :title, :display
          )
  end
end
