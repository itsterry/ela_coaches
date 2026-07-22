module Coaches
  class AvailabilitiesController < ApplicationController
    expose(:availabilities) { Current.coach.availabilities.order(date: :desc, start_time: :asc) }
    expose(:availability) { params[:id] ? availabilities.find(params[:id]) : Current.coach.availabilities.build(availability_params) }

    def create
      return render :new, status: :unprocessable_content unless availability.save

      redirect_to coaches_availabilities_path, notice: "Availability created."
    end

    def destroy
      availability.destroy
      redirect_to coaches_availabilities_path, notice: "Availability deleted.", status: :see_other
    end

    def edit; end

    def index; end

    def new; end

    def show; end

    def update
      return render :edit, status: :unprocessable_content unless availability.update(availability_params)

      redirect_to coaches_availabilities_path, notice: "Availability updated.", status: :see_other
    end

    private

    def availability_params
      params.fetch(:availability, {}).permit(:date, :finish_time, :slot_length, :start_time, :status, :zoom)
    end
  end
end
