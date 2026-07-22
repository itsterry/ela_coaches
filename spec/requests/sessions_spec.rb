RSpec.describe "Sessions", type: :request do
  let(:coach) { create(:coach) }

  describe "GET /session/new" do
    it "returns http success" do
      get new_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /session" do
    it "signs the coach in" do
      post session_path, params: { email: coach.email, password: "Password123!" }
      expect(response).to redirect_to root_path
    end

    it "returns to the page that required authentication" do
      get coaches_availabilities_path
      post session_path, params: { email: coach.email, password: "Password123!" }
      expect(response).to redirect_to coaches_availabilities_url
    end

    it "rejects a bad password" do
      post session_path, params: { email: coach.email, password: "wrong" }
      expect(response).to redirect_to new_session_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /session" do
    it "signs the coach out" do
      sign_in_as coach
      delete session_path
      expect(response).to redirect_to new_session_path
    end
  end
end
