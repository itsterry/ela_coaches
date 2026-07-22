RSpec.describe "Availabilities", type: :request do
  describe "GET /" do
    let!(:availability) { create(:availability, :published) }

    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "lists published availabilities as date cards" do
      get root_path
      expect(response.body).to include availability.date.to_fs(:long)
    end

    it "links free slots to the booking form" do
      get root_path
      expect(response.body).to include new_availability_booking_path(availability, start_time: "09:00")
    end

    it "disables taken slots without revealing details" do
      create(:slot, availability: availability, start_time: availability.start_time, player_name: "Secret Player")
      get root_path
      expect(response.body).to_not include "Secret Player"
      expect(response.body).to include "disabled"
    end

    it "does not list draft availabilities" do
      draft = create(:availability, date: Date.current + 3.weeks)
      get root_path
      expect(response.body).to_not include new_availability_booking_path(draft, start_time: "09:00")
    end

    it "does not list past availabilities" do
      past = create(:availability, :published, date: Date.current - 1.day)
      get root_path
      expect(response.body).to_not include new_availability_booking_path(past, start_time: "09:00")
    end
  end
end
