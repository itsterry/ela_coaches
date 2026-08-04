class CancellationsController < ApplicationController
  allow_unauthenticated_access

  rescue_from ActiveRecord::RecordNotFound, with: :slot_not_found

  expose(:slot) { Slot.find_by!(uuid: params[:uuid]) }

  def destroy
    send_cancellations
    slot.destroy
    redirect_to root_path, notice: "Your booking is cancelled."
  end

  def show; end

  private

  def send_cancellations
    # Delivered inline: Active Job serialises the slot by global id, which no
    # longer resolves once the booking has been destroyed.
    BookingMailer.parent_cancellation(slot).deliver_now
    BookingMailer.coach_cancellation(slot).deliver_now
  end

  def slot_not_found
    redirect_to root_path, alert: "That booking could not be found. It may already have been cancelled."
  end
end
