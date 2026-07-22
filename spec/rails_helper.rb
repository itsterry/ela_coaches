require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'super_diff/rspec-rails'

require 'morse_spec_helpers'
require 'shoulda/matchers'
require 'factory_bot'
require 'webmock/rspec'

include MorseSpecHelpers

SimpleCov.minimum_coverage 100
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([ SimpleCov::Formatter::HTMLFormatter ])

SimpleCov.start do
  skip '.gems'
  skip 'config'
  skip 'pkg'
  skip 'spec'
  skip 'vendor'
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

FactoryBot.factories.clear

FactoryBot.define do
  sequence(:email) { |n| "test#{n}@test.com" }
  sequence(:firstname) { |n| "name#{n}" }
  sequence(:lastname) { |n| "name#{n}" }
  sequence(:slug) { |n| "slug#{n}#{rand(1_000_000)}" }
  sequence(:title) { |n| "title#{n}" }
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| load f }

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.include ActiveSupport::Testing::TimeHelpers
  config.include FactoryBot::Syntax::Methods
  config.example_status_persistence_file_path = [ Rails.root, 'tmp/rspec_failures.txt' ].join('/')
  config.include MorseSpecHelpers
  config.include SpecHelpers::Controllers, type: :controller
  config.include SpecHelpers::Requests, type: :request
  config.include SpecHelpers::Views, type: :view
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false
  end
  config.profile_examples = 0
end

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
