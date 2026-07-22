class PasswordsMailer < ApplicationMailer
  def reset(coach)
    mail subject: "Reset your password", to: coach.email do |format|
      format.html { render locals: { coach: coach } }
      format.text { render locals: { coach: coach } }
    end
  end
end
