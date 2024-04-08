class SessionsController < ApplicationController

  def create
    user_password = params[:session][:password]
    user_email = params[:session][:email]
    unless user_email
      render json: { errors: 'Bad request', success: false }, status: :bad_request
    end

    user = User.find_by_email(user_email)

    if user.valid_password? user_password
      sign_in user, store: false
      user.save
      render json: { data: user, success: true }, status: :ok, location: user
    else
      render json: { errors: user.errors, success: false }, status: :unprocessable_entity
    end
  end

  private

end
