class EmergenciesController < ApplicationController
  def new
  end

  def create
    @emergency = Emergency.new(emergency_params)
    if @emergency.save
      render json: { emergency: @emergency }, status: 201
    end
  end

  def show
    @emergency = Emergency.find(params[:id])
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end
end
