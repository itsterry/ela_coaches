RSpec.describe BookingMailer, type: :mailer do
  let(:availability) { create(:availability, :published, date: Date.parse("2026-09-01"), start_time: "09:00") }
  let(:slot) { create(:slot, availability: availability, parent_email: "parent@test.com", parent_name: "A Parent", player_name: "A Player", start_time: "09:30") }

  describe "#coach_cancellation" do
    let(:mail) { described_class.coach_cancellation(slot) }

    it "is addressed to the coach" do
      expect(mail.to).to eq [ availability.coach.email ]
    end

    it "has a subject naming the player" do
      expect(mail.subject).to eq "Cancelled: A Player on September 01, 2026 at 09:30"
    end

    it "names the parent who cancelled" do
      expect(mail.body.encoded).to include "A Parent"
    end
  end

  describe "#coach_notification" do
    let(:mail) { described_class.coach_notification(slot) }

    it "is addressed to the coach" do
      expect(mail.to).to eq [ availability.coach.email ]
    end

    it "is sent from the bookings address" do
      expect(mail.from).to eq [ "bookings@elacoaches.com" ]
    end

    it "replies to the parent" do
      expect(mail.reply_to).to eq [ "parent@test.com" ]
    end

    it "has a subject naming the player" do
      expect(mail.subject).to eq "New booking: A Player on September 01, 2026 at 09:30"
    end

    it "includes the parent contact details" do
      expect(mail.body.encoded).to include "A Parent"
      expect(mail.body.encoded).to include "parent@test.com"
    end
  end

  describe "#parent_cancellation" do
    let(:mail) { described_class.parent_cancellation(slot) }

    it "is addressed to the parent" do
      expect(mail.to).to eq [ "parent@test.com" ]
    end

    it "has a subject naming the date and time" do
      expect(mail.subject).to eq "Your booking on September 01, 2026 at 09:30 is cancelled"
    end

    it "names the coach and player" do
      expect(mail.body.encoded).to include availability.coach.name
      expect(mail.body.encoded).to include "A Player"
    end
  end

  describe "#parent_confirmation" do
    let(:mail) { described_class.parent_confirmation(slot) }

    it "is addressed to the parent" do
      expect(mail.to).to eq [ "parent@test.com" ]
    end

    it "is sent from the bookings address" do
      expect(mail.from).to eq [ "bookings@elacoaches.com" ]
    end

    it "replies to the coach" do
      expect(mail.reply_to).to eq [ availability.coach.email ]
    end

    it "has a subject naming the date and time" do
      expect(mail.subject).to eq "Your booking on September 01, 2026 at 09:30"
    end

    it "links to the cancellation page" do
      expect(mail.body.encoded).to include cancellation_url(slot.uuid, host: "example.com")
    end

    it "includes the coach, player and location" do
      expect(mail.body.encoded).to include availability.coach.name
      expect(mail.body.encoded).to include "A Player"
      expect(mail.body.encoded).to include "Face to face"
    end
  end
end
