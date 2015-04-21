class ApplicationController < ActionController::Base
  private

  def page_not_found
    render json: { message: 'page not found' }, status: 404
  end

  def show_errors(exception)
    @error = exception.message
    render json: { message: @error }, status: 422
  end
end
