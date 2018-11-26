class BackgroundsController < ApplicationController
  before_action :set_background, only: [:destroy]
  before_action :authenticate_user!, except: [:index]

  # GET /backgrounds
  def index
    @backgrounds = Background.all

    render json: @backgrounds
  end

  # POST /backgrounds
  def create
    @background = Background.new(background_params)

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

  # Use callbacks to share common setup or constraints between actions.
  def set_background
    @background = Background.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def background_params
    params.fetch(:background, {})
          .permit(
            :cover_image, :author_id
          )
  end
end
