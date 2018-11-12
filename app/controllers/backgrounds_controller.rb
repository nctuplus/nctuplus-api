class BackgroundsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :set_background, only: [:destroy]

  # GET /backgrounds
  def index
    @backgrounds = Background.all

    render json: @backgrounds
  end

  # POST/backgrounds
  def create
    @background = Background.new(background_params)
    @background.author_id = current_user.id

    if @background.save
      render json: @background, status: :created, location: @background
    else
      render json: @background.errors, status: :unprocessable_entity
    end
  end

  # DELETE /backgrounds/:id
  def destroy
    @background.destroy
  end

  private

  def set_background
    @background = Background.find(params[:id])
  end

  def background_params
    params.fetch(:background, {})
          .permit(
            :auther_id, :cover_image
          )
  end
end
