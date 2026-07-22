class AvailabilitiesController < ApplicationController
  allow_unauthenticated_access

  expose(:availabilities) { Availability.published.upcoming.includes(:coach, :slots).order(:date, :start_time) }

  def index; end
end
