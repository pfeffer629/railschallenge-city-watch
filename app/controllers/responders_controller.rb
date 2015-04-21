class RespondersController < ApplicationController
  before_action :find_responder, only: [:show, :update]
  rescue_from ActionController::UnpermittedParameters, with: :show_errors

  def new
    page_not_found
  end

  def edit
    page_not_found
  end

  def destroy
    page_not_found
  end

  def index
    @responders = Responder.all
    if @responders.empty?
      render json: { responders: [] }
    else
      render json: { responders: @responders }, status: 200
    end
  end

  def create
    @responder = Responder.new(responder_params)
    if @responder.save
      render json: { responder: @responder }, status: 201
    else
      @errors = @responder.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  def show
    @responder = Responder.find_by(name: params[:id])
    if @responder
      render json: { responder: @responder }
    else
      render json: {}, status: 404
    end
  end

  def update
    @responder = Responder.find_by(name: params[:id])
    @responder.on_duty = params['responder']['on_duty']
    render json: { responder: @responder }
  end

  private

  def responder_params
    params.require(:responder).permit(:emergency_code, :type, :name, :capacity, :on_duty)
  end

  def find_responder
    @responder = Responder.find_by(name: params[:id])
  end
end
