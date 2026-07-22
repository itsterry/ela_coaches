class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :coach, to: :session, allow_nil: true
end
