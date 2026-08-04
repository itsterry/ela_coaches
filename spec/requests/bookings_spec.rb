RSpec.describe "Bookings", type: :request do
  let(:availability) { create(:availability, :published) }
  let(:slot_params) { { parent_email: "parent@test.com", parent_name: "A Parent", player_name: "A Player", start_time: "09:30" } }
  let(:valid_params) { { "slot" => slot_params, "cf-turnstile-response" => "a-token" } }

  before { stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify").to_return(body: { success: true }.to_json) }

  describe "GET /availabilities/:availability_id/bookings/new" do
    it "returns http success" do
      get new_availability_booking_path(availability, start_time: "09:30")
      expect(response).to have_http_status(:success)
    end

    it "preselects the requested start time" do
      get new_availability_booking_path(availability, start_time: "09:30")
      expect(response.body).to include "09:30"
    end

    it "renders the turnstile widget" do
      get new_availability_booking_path(availability, start_time: "09:30")
      expect(response.body).to include Turnstile.site_key
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

    it "emails the parent and the coach" do
      expect {
        perform_enqueued_jobs { post availability_bookings_path(availability), params: valid_params }
      }.to change { ActionMailer::Base.deliveries.count }.by(2)

      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array [ "parent@test.com", availability.coach.email ]
    end

    it "does not email when the booking is invalid" do
      expect {
        perform_enqueued_jobs { post availability_bookings_path(availability), params: valid_params.merge("slot" => slot_params.merge(player_name: "")) }
      }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it "re-renders the form when the booking is invalid" do
      post availability_bookings_path(availability), params: valid_params.merge("slot" => slot_params.merge(parent_email: "", parent_name: "", player_name: ""))
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "allows only one booking per parent email" do
      post availability_bookings_path(availability), params: valid_params

      expect {
        post availability_bookings_path(availability), params: valid_params.merge("slot" => slot_params.merge(start_time: "10:00"))
      }.to_not change(Slot, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include "has already booked a slot for this session"
    end

    context "when the turnstile challenge fails" do
      before { stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify").to_return(body: { success: false }.to_json) }

      it "does not book the slot" do
        expect {
          post availability_bookings_path(availability), params: valid_params
        }.to_not change(Slot, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to be_present
      end
    end

    it "allows the same parent to book a different availability" do
      other = create(:availability, :published, date: Date.current + 2.weeks)
      post availability_bookings_path(availability), params: valid_params

      expect {
        post availability_bookings_path(other), params: valid_params
      }.to change(Slot, :count).by(1)
    end
  end
end
