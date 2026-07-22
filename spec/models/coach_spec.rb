RSpec.describe Coach, type: :model do
  subject { build(:coach) }

  describe "associations" do
    it { is_expected.to have_many(:availabilities).dependent(:destroy) }
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to validate_presence_of(:email) }

    it "requires a unique email" do
      create(:coach, email: "taken@test.com")
      expect(build(:coach, email: "taken@test.com")).to_not be_valid
    end

    it { is_expected.to allow_value("coach@test.com").for(:email) }
    it { is_expected.to_not allow_value("coach@test").for(:email) }
    it { is_expected.to_not allow_value("nonsense").for(:email) }
  end

  describe "normalisation" do
    it "downcases and strips the email" do
      coach = create(:coach, email: "  MiXeD@Test.COM ")
      expect(coach.email).to eq "mixed@test.com"
    end
  end

  describe "authentication" do
    it "authenticates with the correct password" do
      coach = create(:coach)
      expect(Coach.authenticate_by(email: coach.email, password: "Password123!")).to eq coach
    end
  end

  describe "#name" do
    it "joins the firstname and lastname" do
      coach = build(:coach, firstname: "Ada", lastname: "Lovelace")
      expect(coach.name).to eq "Ada Lovelace"
    end
  end

  describe "friendly_id" do
    it "slugs from the name" do
      coach = create(:coach, firstname: "Ada", lastname: "Lovelace")
      expect(coach.slug).to eq "ada-lovelace"
    end

    it "is found by its slug" do
      coach = create(:coach, firstname: "Ada", lastname: "Lovelace")
      expect(Coach.friendly.find("ada-lovelace")).to eq coach
    end

    it "regenerates the slug when the name changes" do
      coach = create(:coach, firstname: "Ada", lastname: "Lovelace")
      coach.update(lastname: "Byron")
      expect(coach.slug).to eq "ada-byron"
    end

    it "keeps the slug when the name is unchanged" do
      coach = create(:coach, firstname: "Ada", lastname: "Lovelace")
      coach.update(zoom_client_id: "changed")
      expect(coach.slug).to eq "ada-lovelace"
    end
  end
end
