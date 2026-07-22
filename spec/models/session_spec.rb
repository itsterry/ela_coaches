RSpec.describe Session, type: :model do
  subject { build(:coach).sessions.build }

  it { is_expected.to belong_to(:coach) }
end
