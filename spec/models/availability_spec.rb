RSpec.describe Availability, type: :model do
  subject { build(:availability) }

  describe "associations" do
    it { is_expected.to belong_to(:coach) }
    it { is_expected.to have_many(:slots).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:finish_time) }
    it { is_expected.to validate_numericality_of(:slot_length).is_greater_than(0) }
    it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }

    context "when the finish time is before the start time" do
      subject { build(:availability, start_time: "12:00", finish_time: "09:00") }

      it { is_expected.to_not be_valid }
    end

    context "when the finish time equals the start time" do
      subject { build(:availability, start_time: "09:00", finish_time: "09:00") }

      it { is_expected.to_not be_valid }
    end

    context "when the finish time is missing" do
      subject { build(:availability, finish_time: nil) }

      it "does not add a finish time ordering error" do
        subject.valid?
        expect(subject.errors[:finish_time]).to_not include "must be after the start time"
      end
    end
  end

  describe "defaults" do
    it "is a draft" do
      expect(described_class.new.status).to eq "draft"
    end

    it "is not a zoom session" do
      expect(described_class.new.zoom).to be false
    end
  end

  describe ".published" do
    it "returns only published availabilities" do
      published = create(:availability, :published)
      create(:availability)
      expect(described_class.published).to eq [ published ]
    end
  end

  describe ".upcoming" do
    it "excludes availabilities in the past" do
      upcoming = create(:availability, date: Date.current)
      create(:availability, date: Date.current - 1.day)
      expect(described_class.upcoming).to eq [ upcoming ]
    end
  end

  describe "#free_times" do
    it "excludes times that are already taken" do
      availability = create(:availability)
      create(:slot, availability: availability, start_time: availability.start_time)
      expect(availability.reload.free_times).to eq availability.slot_times.drop(1)
    end
  end

  describe "#full?" do
    it "is false while free times remain" do
      expect(create(:availability)).to_not be_full
    end

    it "is true when every slot is taken" do
      availability = create(:availability)
      availability.slot_times.each { |time| create(:slot, availability: availability, start_time: time) }
      expect(availability.reload).to be_full
    end
  end

  describe "#location" do
    it "is Zoom for a zoom availability" do
      expect(build(:availability, zoom: true).location).to eq "Zoom"
    end

    it "is Face to face otherwise" do
      expect(build(:availability, zoom: false).location).to eq "Face to face"
    end
  end

  describe "#published?" do
    it "is true when published" do
      expect(build(:availability, :published)).to be_published
    end

    it "is false when draft" do
      expect(build(:availability)).to_not be_published
    end
  end

  describe "#slot_times" do
    it "steps from the start time by the slot length" do
      availability = build(:availability, start_time: "09:00", finish_time: "10:00", slot_length: 30)
      expect(availability.slot_times.map { |time| time.strftime("%H:%M") }).to eq %w[09:00 09:30]
    end

    it "omits a trailing slot that does not fit" do
      availability = build(:availability, start_time: "09:00", finish_time: "10:15", slot_length: 30)
      expect(availability.slot_times.map { |time| time.strftime("%H:%M") }).to eq %w[09:00 09:30]
    end

    it "is empty without the times needed to calculate it" do
      expect(described_class.new.slot_times).to eq []
    end
  end

  describe "#taken?" do
    it "is true for a booked time" do
      availability = create(:availability)
      create(:slot, availability: availability, start_time: availability.start_time)
      expect(availability.reload).to be_taken availability.start_time
    end

    it "is false for a free time" do
      availability = create(:availability)
      expect(availability).to_not be_taken availability.start_time
    end
  end
end
