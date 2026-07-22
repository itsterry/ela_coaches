class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :ensure_coach_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  expose(:coach) { Coach.find_by_password_reset_token!(params[:token]) }

  def create
    PasswordsMailer.reset(coach_by_email).deliver_later if coach_by_email
    redirect_to new_session_path, notice: "Password reset instructions sent (if a coach with that email address exists)."
  end

  def edit; end

  def new; end

  def update
    return redirect_to edit_password_path(params[:token]), alert: "Passwords did not match." unless coach.update(password_params)

    coach.sessions.destroy_all
    redirect_to new_session_path, notice: "Password has been reset."
  end

  private

  def coach_by_email
    @coach_by_email ||= Coach.find_by(email: params[:email])
  end

  def ensure_coach_by_token
    coach
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end
end
