class BookingMailer < ApplicationMailer
  def coach_cancellation(slot)
    mail subject: "Cancelled: #{slot.player_name} on #{when_booked(slot)}",
         to: slot.availability.coach.email,
         reply_to: slot.parent_email do |format|
      format.html { render locals: { slot: slot } }
      format.text { render locals: { slot: slot } }
    end
  end

  def coach_notification(slot)
    mail subject: "New booking: #{slot.player_name} on #{when_booked(slot)}",
         to: slot.availability.coach.email,
         reply_to: slot.parent_email do |format|
      format.html { render locals: { slot: slot } }
      format.text { render locals: { slot: slot } }
    end
  end

  def parent_cancellation(slot)
    mail subject: "Your booking on #{when_booked(slot)} is cancelled",
         to: slot.parent_email,
         reply_to: slot.availability.coach.email do |format|
      format.html { render locals: { slot: slot } }
      format.text { render locals: { slot: slot } }
    end
  end

  def parent_confirmation(slot)
    mail subject: "Your booking on #{when_booked(slot)}",
         to: slot.parent_email,
         reply_to: slot.availability.coach.email do |format|
      format.html { render locals: { slot: slot } }
      format.text { render locals: { slot: slot } }
    end
  end

  private

  def when_booked(slot)
    "#{slot.availability.date.to_fs(:long)} at #{slot.start_time.strftime("%H:%M")}"
  end
end
