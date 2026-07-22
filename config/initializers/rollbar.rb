Rollbar.configure do |config|
  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  config.enabled = false if Rails.env.local?
  config.environment = ENV.fetch("ROLLBAR_ENV", Rails.env)
end
