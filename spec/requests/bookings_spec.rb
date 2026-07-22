RSpec.describe "Bookings", type: :request do
  let(:availability) { create(:availability, :published) }
  let(:valid_params) { { slot: { parent_name: "A Parent", player_name: "A Player", start_time: "09:30" } } }

  describe "GET /availabilities/:availability_id/bookings/new" do
    it "returns http success" do
      get new_availability_booking_path(availability, start_time: "09:30")
      expect(response).to have_http_status(:success)
    end

    it "preselects the requested start time" do
      get new_availability_booking_path(availability, start_time: "09:30")
      expect(response.body).to include "09:30"
    end

    it "is not available for a draft availability" do
      get new_availability_booking_path(create(:availability), start_time: "09:30")
      expect(response).to redirect_to root_path
    end
  end

  describe "POST /availabilities/:availability_id/bookings" do
    it "books the slot" do
      expect {
        post availability_bookings_path(availability), params: valid_params
      }.to change(Slot, :count).by(1)
      expect(response).to redirect_to root_path
    end

    it "re-renders the form when the booking is invalid" do
      post availability_bookings_path(availability), params: { slot: { parent_name: "", player_name: "", start_time: "09:30" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "allows only one booking per availability" do
      post availability_bookings_path(availability), params: valid_params

      expect {
        post availability_bookings_path(availability), params: { slot: { parent_name: "A Parent", player_name: "A Player", start_time: "10:00" } }
      }.to_not change(Slot, :count)

      expect(response).to redirect_to root_path
      expect(flash[:alert]).to be_present
    end

    it "allows a booking on a different availability" do
      other = create(:availability, :published, date: Date.current + 2.weeks)
      post availability_bookings_path(availability), params: valid_params

      expect {
        post availability_bookings_path(other), params: valid_params
      }.to change(Slot, :count).by(1)
    end
  end
end
