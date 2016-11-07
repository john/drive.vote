module Api
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception, prepend: true

    rescue_from(ActionController::RoutingError, ActionController::UnknownController, ActiveRecord::RecordNotFound) do
      render json: {error: 'Not found'}, status: 404
    end

  end
end

