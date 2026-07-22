module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_coach

    def connect
      set_current_coach || reject_unauthorized_connection
    end

    private

    def set_current_coach
      session = Session.find_by(id: cookies.signed[:session_id])
      self.current_coach = session.coach if session
    end
  end
end
