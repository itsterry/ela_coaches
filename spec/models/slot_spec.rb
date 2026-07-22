RSpec.describe Slot, type: :model do
  subject { build(:slot) }

  describe "associations" do
    it { is_expected.to belong_to(:availability) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:parent_name) }
    it { is_expected.to validate_presence_of(:player_name) }
    it { is_expected.to validate_presence_of(:start_time) }

    it "allows only one booking per start time" do
      slot = create(:slot)
      expect(build(:slot, availability: slot.availability, start_time: slot.start_time)).to_not be_valid
    end

    context "when the start time is outside the availability" do
      subject { build(:slot, start_time: "13:00") }

      it { is_expected.to_not be_valid }
    end

    context "when the start time is inside the availability but off the grid" do
      subject { build(:slot, start_time: "09:10") }

      it { is_expected.to_not be_valid }
    end

    context "when the start time is a valid slot time" do
      subject { build(:slot, start_time: "09:30") }

      it { is_expected.to be_valid }
    end

    context "without an availability" do
      subject { build(:slot, availability: nil) }

      it "does not add a start time error" do
        subject.valid?
        expect(subject.errors[:start_time]).to_not include "must be within the availability"
      end
    end
  end
end
