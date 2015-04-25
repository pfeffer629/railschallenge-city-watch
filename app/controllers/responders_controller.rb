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
    if params[:show] == 'capacity'
      display_capacity
      render json: { capacity: @capacity }
    end

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
      render :show
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

  def display_capacity
    @capacity = {
      'Fire' => [0, 0, 0, 0],
      'Police' => [0, 0, 0, 0],
      'Medical' => [0, 0, 0, 0]
    }
    calculate_capacity
    @capacity
  end

  def calculate_capacity
    @responders.each do |responder|
      next if responder_ready?(responder)
      next if responder_on_duty?(responder)
      next if responder_available?(responder)
      responder_total?(responder)
    end
  end

  def responder_ready?(responder)
    if responder.emergency_code.nil? && responder.on_duty == true
      @capacity["#{responder.type}"].map! { |total| total + responder.capacity }
      return true
    end
    false
  end

  def responder_on_duty?(responder)
    if responder.on_duty == true
      @capacity["#{responder.type}"][2] += responder.capacity
      @capacity["#{responder.type}"][0] += responder.capacity
      return true
    end
    false
  end

  def responder_available?(responder)
    if responder.emergency_code.nil?
      @capacity["#{responder.type}"][1] += responder.capacity
      @capacity["#{responder.type}"][0] += responder.capacity
      return true
    end
    false
  end

  def responder_total?(responder)
    @capacity["#{responder.type}"][0] += responder.capacity
  end
end
