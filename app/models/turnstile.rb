require "net/http"

class Turnstile
  VERIFY_URL = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")

  def self.secret_key
    Rails.application.credentials.dig(:turnstile, :secret_key)
  end

  def self.site_key
    Rails.application.credentials.dig(:turnstile, :site_key)
  end

  def self.verified?(token:, ip: nil)
    new(token: token, ip: ip).verified?
  end

  def initialize(token:, ip: nil)
    @ip = ip
    @token = token
  end

  def verified?
    return false if token.blank?

    outcome["success"] == true
  end

  private

  attr_reader :ip, :token

  def form_data
    { "secret" => self.class.secret_key, "response" => token, "remoteip" => ip }.compact
  end

  def outcome
    JSON.parse(Net::HTTP.post_form(VERIFY_URL, form_data).body)
  rescue StandardError => error
    Rollbar.error(error)
    {}
  end
end
