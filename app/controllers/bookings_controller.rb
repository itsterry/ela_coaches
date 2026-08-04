class BookingsController < ApplicationController
  allow_unauthenticated_access

  rescue_from ActiveRecord::RecordNotFound, with: :availability_not_found

  expose(:availability) { Availability.published.upcoming.find(params[:availability_id]) }
  expose(:slot) { availability.slots.build(slot_params) }

  def create
    return challenge_failed unless turnstile_verified?
    return render :new, status: :unprocessable_content unless slot.save

    send_confirmations
    redirect_to root_path, notice: "Your slot is booked."
  end

  def new; end

  private

  def availability_not_found
    redirect_to root_path, alert: "That session is no longer available."
  end

  def challenge_failed
    flash.now[:alert] = "We could not confirm you are human. Please try again."
    render :new, status: :unprocessable_content
  end

  def default_slot_params
    ActionController::Parameters.new(start_time: params[:start_time])
  end

  def send_confirmations
    BookingMailer.parent_confirmation(slot).deliver_later
    BookingMailer.coach_notification(slot).deliver_later
  end

  def slot_params
    params.fetch(:slot, default_slot_params).permit(:parent_email, :parent_name, :player_name, :start_time)
  end

  def turnstile_verified?
    Turnstile.verified?(token: params["cf-turnstile-response"], ip: request.remote_ip)
  end
end
