class RespondersController < ApplicationController
  before_action :page_not_found, only: [:new, :edit, :destroy]
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
    if params
      show_capacity
    elsif @responders.empty?
      render json: { responders: [] }
    else
      render json: { responders: @responders }, status: 200
    end
  end

  def create
    @responder = Responder.new(create_responder_params)
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

  def show_capacity
    @capacity = { Fire: [0, 0, 0, 0],
      Police: [0, 0, 0, 0],
      Medical: [0, 0, 0, 0] }
    @responders.each do |responder|
      if responder.type == 'Fire'
        @capacity[Fire][0] += 1
        @capacity[Fire][1] += 1
        if responder.on_duty
          @capacity[Fire][2] += 1
          @capacity[Fire][3] += 1
        end
      elsif responder.type == 'Police'
        @capacity[Police][0] += 1
        @capacity[Police][1] += 1
        if responder.on_duty
          @capacity[Police][2] += 1
          @capacity[Police][3] += 1
        end
      else
        @capacity[Medical][0] += 1
        @capacity[Medical][1] += 1
        if responder.on_duty
          @capacity[Medical][2] += 1
          @capacity[Medical][3] += 1
        end
      end
    end
    render json: { capacity: @capacity }
  end
end
