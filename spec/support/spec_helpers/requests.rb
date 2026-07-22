module SpecHelpers
  module Requests
    def exposes(variable)
      expect(controller.send(variable)).to_not be_nil
    end

    def returns_200
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    def sign_in_coach
      sign_in_as coach_persisted
    end
  end
end
