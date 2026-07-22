RSpec.describe "Coaches::Availabilities", type: :request do
  let(:coach) { create(:coach) }
  let(:availability) { create(:availability, coach: coach) }
  let(:valid_params) do
    { availability: { date: Date.current + 1.week, start_time: "09:00", finish_time: "12:00", slot_length: 30, zoom: true, status: "published" } }
  end

  context "when signed out" do
    it "redirects to the sign in page" do
      get coaches_availabilities_path
      expect(response).to redirect_to new_session_path
    end
  end

  context "when signed in" do
    before { sign_in_as coach }

    describe "GET /index" do
      it "returns http success" do
        availability
        get coaches_availabilities_path
        expect(response).to have_http_status(:success)
      end

      it "excludes another coach's availabilities" do
        other = create(:availability)
        get coaches_availabilities_path
        expect(response.body).to_not include coaches_availability_path(other)
      end
    end

    describe "GET /show" do
      it "returns http success" do
        create(:slot, availability: availability)
        get coaches_availability_path(availability)
        expect(response).to have_http_status(:success)
      end

      it "shows the booking details" do
        slot = create(:slot, availability: availability)
        get coaches_availability_path(availability)
        expect(response.body).to include slot.player_name
      end
    end

    describe "GET /new" do
      it "returns http success" do
        get new_coaches_availability_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /create" do
      it "creates the availability" do
        expect {
          post coaches_availabilities_path, params: valid_params
        }.to change(coach.availabilities, :count).by(1)
        expect(response).to redirect_to coaches_availabilities_path
      end

      it "re-renders new when invalid" do
        post coaches_availabilities_path, params: { availability: valid_params[:availability].merge(date: "") }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "GET /edit" do
      it "returns http success" do
        get edit_coaches_availability_path(availability)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /update" do
      it "updates the availability" do
        patch coaches_availability_path(availability), params: { availability: { status: "published" } }
        expect(availability.reload.status).to eq "published"
        expect(response).to redirect_to coaches_availabilities_path
      end

      it "re-renders edit when invalid" do
        patch coaches_availability_path(availability), params: { availability: { date: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "DELETE /destroy" do
      it "destroys the availability" do
        availability
        expect {
          delete coaches_availability_path(availability)
        }.to change(coach.availabilities, :count).by(-1)
        expect(response).to redirect_to coaches_availabilities_path
      end
    end
  end
end
