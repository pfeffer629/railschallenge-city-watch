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
    response_count

    render json: { emergencies: [] } if @emergencies.empty?
  end

  def create
    @emergency = Emergency.new(params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity))

    if @emergency.save
      Responder.dispatch_responders(@emergency)
      if @emergency.full_response
        response_count
        response_message
      end
      responder_names(@emergency)

      render :show, status: 201
    else
      @errors = @emergency.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  def show
    render json: {}, status: 404 if @emergency.nil?
  end

  def update
    if @emergency.update(params.require(:emergency).permit(:fire_severity, :police_severity, :medical_severity, :resolved_at))
      Emergency.resolve_emergency(@emergency) unless @emergency.resolved_at.nil?

      render :show
    else
      @errors = @emergency.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  private
  
  def find_emergency
    @emergency = Emergency.find_by(code: params[:id])
  end

  def response_count
    enough_personnel = Emergency.where(full_response: true).count
    total_emergencies = Emergency.all.count
    @response_count = [enough_personnel, total_emergencies]
  end

  def response_message
    @full_response = "#{@response_count[0]} out of #{@response_count[1]} emergencies had enough personnel."
  end

  def responder_names(emergency)
    @responder_names = []
    emergency.responders.each do |responder|
      @responder_names << responder.name
    end
  end
end
