module Emailable
  extend ActiveSupport::Concern

  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[a-z]{2,}\z/i

  class_methods do
    def has_email(attribute)
      normalizes attribute, with: ->(email) { email.strip.downcase }
      validates attribute, presence: true, format: { with: EMAIL_FORMAT }
    end
  end
end
