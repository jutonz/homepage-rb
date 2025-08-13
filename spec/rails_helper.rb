# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

require "action_text/system_test_helper"
require "capybara/rspec"
require "pundit/rspec"
require "super_diff/rspec-rails"
require "view_component/system_test_helpers"
require "view_component/test_helpers"
require "webmock/rspec"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { require it }

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include Warden::Test::Helpers
  config.after(:each) { Warden.test_reset! }

  config.include ActionText::SystemTestHelper, type: :system
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Capybara::RSpecMatchers, type: :component
  config.include CapybaraPage, type: :request
  config.include FactoryBot::Syntax::Methods
  config.include JsonResponse, type: :request
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include ViewComponent::TestHelpers, type: :component

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless, screen_size: [1400, 900]
  end

  config.before(:each, type: :system, debug: true) do
    driven_by :selenium, using: :chrome, screen_size: [1400, 900]
  end

  config.around(:each) do |example|
    if example.metadata[:type] == :system
      Bullet.start_request
      example.run
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    else
      Bullet.enable = false
      example.run
      Bullet.enable = true
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

WebMock.disable_net_connect!(allow_localhost: true)

Capybara.enable_aria_label = true
