RSpec.describe "Passwords", type: :request do
  let(:coach) { create(:coach) }

  describe "GET /passwords/new" do
    it "returns http success" do
      get new_password_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /passwords" do
    it "sends reset instructions to a known coach" do
      expect {
        post passwords_path, params: { email: coach.email }
      }.to have_enqueued_mail(PasswordsMailer, :reset)
      expect(response).to redirect_to new_session_path
    end

    it "says nothing about an unknown email" do
      expect {
        post passwords_path, params: { email: "nobody@test.com" }
      }.to_not have_enqueued_mail(PasswordsMailer, :reset)
      expect(response).to redirect_to new_session_path
    end
  end

  describe "GET /passwords/:token/edit" do
    it "returns http success" do
      get edit_password_path(coach.password_reset_token)
      expect(response).to have_http_status(:success)
    end

    it "rejects an invalid token" do
      get edit_password_path("nonsense")
      expect(response).to redirect_to new_password_path
    end
  end

  describe "PATCH /passwords/:token" do
    it "resets the password" do
      patch password_path(coach.password_reset_token), params: { password: "NewPassword123!", password_confirmation: "NewPassword123!" }
      expect(response).to redirect_to new_session_path
      expect(coach.reload.authenticate("NewPassword123!")).to be_truthy
    end

    it "rejects a mismatched confirmation" do
      token = coach.password_reset_token
      patch password_path(token), params: { password: "NewPassword123!", password_confirmation: "Different123!" }
      expect(response).to redirect_to edit_password_path(token)
    end
  end
end
