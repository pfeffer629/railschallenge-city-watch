class EmergenciesController < ApplicationController
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
    @emergencies = Emergency.all
    if @emergencies.empty?
      render json: { emergencies: [] }
    else
      render json: { emergencies: @emergencies}, status: 200
    end
  end

  def create
    @emergency = Emergency.new(emergency_params)
    if @emergency.save
      render json: { emergency: @emergency }, status: 201
    else
      @errors = @emergency.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  def show
    @emergency = Emergency.find_by(code: params[:id])
    if @emergency
      render json: { emergency: @emergency }
    else
      render json: {}, status: 404
    end
  end

  def update
    @emergency = Emergency.find_by(code: params[:id])
    @emergency.fire_severity = params['emergency']['fire_severity'].to_i
    @emergency.police_severity = params['emergency']['police_severity'].to_i
    @emergency.medical_severity = params['emergency']['medical_severity'].to_i
    render json: { emergency: @emergency }
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end

  def page_not_found
    render json: { message: 'page not found' }, status: 404
  end
end
