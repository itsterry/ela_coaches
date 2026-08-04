module Coaches
  class SlotsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :slot_not_found

    expose(:slot) { Slot.joins(:availability).where(availabilities: { coach_id: Current.coach.id }).find(params[:id]) }

    def destroy
      availability = slot.availability
      BookingMailer.parent_cancellation(slot).deliver_now
      slot.destroy
      redirect_to coaches_availability_path(availability), notice: "Booking cancelled and the parent has been emailed.", status: :see_other
    end

    private

    def slot_not_found
      redirect_to coaches_availabilities_path, alert: "That booking could not be found."
    end
  end
end
