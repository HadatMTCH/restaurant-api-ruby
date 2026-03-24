class ApplicationController < ActionController::API
  before_action :authenticate_request

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def authenticate_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    if token.present?
      begin
        @decoded = jwt_decode(token)
        @current_user = User.find(@decoded[:user_id])
        raise JWT::DecodeError if @current_user.jti.present? && @current_user.jti != @decoded[:jti]
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        @current_user = User.find_by(api_key: token)
      end
    end

    render json: { message: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  end

  def record_not_found(exception)
    render json: { message: "Data not found", errors: exception.message  }, status: :not_found
  end

  def record_invalid(exception)
    render json: { message: "Validation failed", errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: { message: exception.message }, status: :bad_request
  end
end
