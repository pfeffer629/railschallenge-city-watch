class RespondersController < ApplicationController
  before_action :find_responder, only: [:show, :update]
  rescue_from ActionController::UnpermittedParameters, with: :show_errors

  def new
  end

  def edit
  end

  def destroy
  end

  def index
    @responders = Responder.all

    render json: { responders: [] } if @responders.empty?
  end

  def create
    @responder = Responder.new(create_responder_params)

    if @responder.save
      render :show, status: 201
    else
      @errors = @responder.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  def show
    render json: {}, status: 404 if @responder.nil?
  end

  def update
    if @responder.update(update_responder_params)
      render json: { responder: @responder }
    else
      @errors = @responder.errors.messages
      render json: { message: @errors }
    end
  end

  private

  def create_responder_params
    params.require(:responder).permit(:type, :name, :capacity)
  end

  def update_responder_params
    params.require(:responder).permit(:on_duty)
  end

  def find_responder
    @responder = Responder.find_by(name: params[:id])
  end
end
