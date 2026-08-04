RSpec.describe Slot, type: :model do
  subject { build(:slot) }

  describe "associations" do
    it { is_expected.to belong_to(:availability) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:parent_email) }
    it { is_expected.to validate_presence_of(:parent_name) }
    it { is_expected.to validate_presence_of(:player_name) }
    it { is_expected.to validate_presence_of(:start_time) }

    it { is_expected.to allow_value("parent@test.com").for(:parent_email) }
    it { is_expected.to_not allow_value("parent@test").for(:parent_email) }
    it { is_expected.to_not allow_value("nonsense").for(:parent_email) }

    it "allows only one booking per parent email" do
      slot = create(:slot)
      expect(build(:slot, availability: slot.availability, parent_email: slot.parent_email, start_time: "09:30")).to_not be_valid
    end

    it "matches the parent email regardless of case" do
      slot = create(:slot, parent_email: "parent@test.com")
      expect(build(:slot, availability: slot.availability, parent_email: "PARENT@TEST.COM", start_time: "09:30")).to_not be_valid
    end

    it "allows the same parent email on another availability" do
      slot = create(:slot)
      expect(build(:slot, parent_email: slot.parent_email)).to be_valid
    end

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

  describe "uuid" do
    it "is assigned on create" do
      expect(create(:slot).uuid).to match(/\A[0-9a-f-]{36}\z/)
    end

    it "is unique per slot" do
      expect(create(:slot).uuid).to_not eq create(:slot).uuid
    end

    it "keeps a uuid that was supplied" do
      expect(create(:slot, uuid: "11111111-1111-1111-1111-111111111111").uuid).to eq "11111111-1111-1111-1111-111111111111"
    end

    it "does not change when the slot is updated" do
      slot = create(:slot)
      expect { slot.update!(player_name: "Someone Else") }.to_not change { slot.reload.uuid }
    end
  end

  describe "normalisation" do
    it "downcases and strips the parent email" do
      slot = create(:slot, parent_email: "  MiXeD@Test.COM ")
      expect(slot.parent_email).to eq "mixed@test.com"
    end
  end
end
