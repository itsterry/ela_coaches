class BookingsController < ApplicationController
  allow_unauthenticated_access

  rescue_from ActiveRecord::RecordNotFound, with: :availability_not_found

  before_action :ensure_availability_not_booked

  expose(:availability) { Availability.published.upcoming.find(params[:availability_id]) }
  expose(:slot) { availability.slots.build(slot_params) }

  def create
    return render :new, status: :unprocessable_content unless slot.save

    remember_booking
    redirect_to root_path, notice: "Your slot is booked."
  end

  def new; end

  private

  def availability_not_found
    redirect_to root_path, alert: "That session is no longer available."
  end

  def booked_availability_ids
    session[:booked_availability_ids] ||= []
  end

  def default_slot_params
    ActionController::Parameters.new(start_time: params[:start_time])
  end

  def ensure_availability_not_booked
    return unless booked_availability_ids.include?(availability.id)

    redirect_to root_path, alert: "You have already booked a slot for this session."
  end

  def remember_booking
    session[:booked_availability_ids] = booked_availability_ids + [ availability.id ]
  end

  def slot_params
    params.fetch(:slot, default_slot_params).permit(:parent_name, :player_name, :start_time)
  end
end
