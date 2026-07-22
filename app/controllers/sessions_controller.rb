class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def create
    coach = Coach.authenticate_by(params.permit(:email, :password))
    return redirect_to new_session_path, alert: "Try another email address or password." unless coach

    start_new_session_for coach
    redirect_to after_authentication_url
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  def new; end
end
