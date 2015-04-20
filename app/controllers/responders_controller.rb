class RespondersController < ApplicationController
  def create
    @responder = Responder.new(responder_params)
    if @responder.save
      render json: {
        'responder' => {
          'emergency_code' => @responder.emergency_code,
          'type' => @responder.type,
          'name' => @responder.name,
          'capacity' => @responder.capacity,
          'on_duty' => @responder.on_duty
        }
      }, status: 201
    else
      @errors = @responder.errors.messages
      render json: { message: @errors }, status: 422
    end
  end

  private
    def responder_params
      params.require(:responder).permit(:emergency_code, :type, :name, :capacity, :on_duty)
    end
end
