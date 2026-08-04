RSpec.describe "Coaches::Slots", type: :request do
  let(:coach) { create(:coach) }
  let(:availability) { create(:availability, coach: coach) }
  let(:slot) { create(:slot, availability: availability) }

  context "when signed out" do
    it "redirects to the sign in page" do
      delete coaches_slot_path(slot)
      expect(response).to redirect_to new_session_path
    end

    it "does not cancel the booking" do
      slot
      expect { delete coaches_slot_path(slot) }.to_not change(Slot, :count)
    end
  end

  context "when signed in" do
    before { sign_in_as coach }

    describe "DELETE /destroy" do
      it "cancels the booking" do
        slot
        expect { delete coaches_slot_path(slot) }.to change(Slot, :count).by(-1)
        expect(response).to redirect_to coaches_availability_path(availability)
        expect(flash[:notice]).to be_present
      end

      it "emails the parent" do
        slot

        expect { delete coaches_slot_path(slot) }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq [ slot.parent_email ]
      end

      it "does not cancel another coach's booking" do
        other = create(:slot)

        expect { delete coaches_slot_path(other) }.to_not change(Slot, :count)
        expect(response).to redirect_to coaches_availabilities_path
        expect(flash[:alert]).to be_present
      end
    end
  end
end
