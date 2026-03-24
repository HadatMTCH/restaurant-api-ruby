class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [ :login ]

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      user.update!(jti: SecureRandom.uuid)
      token = jwt_encode(user_id: user.id, jti: user.jti)
      render json: { token: token }, status: :ok
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def logout
    @current_user.update!(jti: SecureRandom.uuid)
    render json: { message: "Logged out successfully" }, status: :ok
  end

  private

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
