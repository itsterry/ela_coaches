RSpec.describe "Cancellations", type: :request do
  let(:availability) { create(:availability, :published) }
  let(:slot) { create(:slot, availability: availability, player_name: "A Player", start_time: "09:30") }

  describe "GET /cancellations/:uuid" do
    it "returns http success" do
      get cancellation_path(slot.uuid)
      expect(response).to have_http_status(:success)
    end

    it "shows the booking details" do
      get cancellation_path(slot.uuid)
      expect(response.body).to include "A Player"
      expect(response.body).to include "09:30"
    end

    it "does not cancel the booking" do
      slot
      expect { get cancellation_path(slot.uuid) }.to_not change(Slot, :count)
    end

    it "redirects when the uuid is unknown" do
      get cancellation_path("does-not-exist")
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /cancellations/:uuid" do
    it "cancels the booking" do
      slot
      expect { delete cancellation_path(slot.uuid) }.to change(Slot, :count).by(-1)
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to be_present
    end

    it "emails the parent and the coach" do
      slot

      expect { delete cancellation_path(slot.uuid) }.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array [ slot.parent_email, availability.coach.email ]
    end

    it "does not email when the uuid is unknown" do
      slot
      expect { delete cancellation_path("does-not-exist") }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it "frees the slot time for another parent" do
      delete cancellation_path(slot.uuid)
      expect(availability.reload.free_times).to include slot.start_time
    end

    it "redirects when the uuid is unknown" do
      slot
      expect { delete cancellation_path("does-not-exist") }.to_not change(Slot, :count)
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to be_present
    end
  end
end
