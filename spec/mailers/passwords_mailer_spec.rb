RSpec.describe PasswordsMailer, type: :mailer do
  describe "#reset" do
    let(:coach) { create(:coach) }
    let(:mail) { described_class.reset(coach) }

    it "is addressed to the coach" do
      expect(mail.to).to eq [ coach.email ]
    end

    it "has a subject" do
      expect(mail.subject).to eq "Reset your password"
    end

    it "links to the reset page" do
      expect(mail.body.encoded).to include "passwords/"
    end
  end
end
