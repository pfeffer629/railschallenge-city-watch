class EmergenciesController < ApplicationController
  before_action :find_emergency, only: [:show, :update]
  rescue_from ActionController::UnpermittedParameters, with: :show_errors

  def new
  end

  def edit
  end

  def destroy
  end

  def index
    @emergencies = Emergency.all

    if @emergencies.empty?
      render json: { emergencies: [] }
    else
      render json: { emergencies: @emergencies }, status: 200
    end
  end

  def create
    @emergency = Emergency.new(create_emergency_params)

    if @emergency.save
      # dispatch_responders(@emergency)
      render json: { emergency: @emergency }, status: 201
    else
      @errors = @emergency.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  def show
    if @emergency
      render json: { emergency: @emergency }
    else
      render json: {}, status: 404
    end
  end

  def update
    if @emergency.update(update_emergency_params)
      render json: { emergency: @emergency }
    else
      @errors = @emergency.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  private

  def create_emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end

  def update_emergency_params
    params.require(:emergency).permit(:fire_severity, :police_severity, :medical_severity, :resolved_at)
  end

  def find_emergency
    @emergency = Emergency.find_by(code: params[:id])
  end

  # def dispatch_responders(emergency)
  #   fire_severity = emergency.fire_severity
  #   police_severity = emergency.police_severity
  #   medical_severity = emergency.medical_severity

  #   responders = Responder.where(type: "Fire").order(capacity: :desc)
  #   calculate_responders(responders, fire_severity)
  # end

  # def calculate_responders(responders, severity)
  #   responders_hash = {}
  #   @answer = {}
  #   responders.each do |responder|
  #     responders_hash[responder.name] = responder.capacity
  #   end
  #   if responders.key(severity)
  #     @answer = { responders.key(severity): severity }
  #   else
  #   end
  # end
end
