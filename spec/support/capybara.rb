require "capybara/playwright"

playwright_cli_version = Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip
playwright_cli_executable_path =
  "npx playwright@#{playwright_cli_version}"
PLAWRIGHT_OPTS = {
  playwright_cli_executable_path:,
  browser_type: :chromium,
  viewport: {width: 1400, height: 900}
}.freeze

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    **PLAWRIGHT_OPTS,
    headless: true
  )
end

Capybara.register_driver(:playwright_debug) do |app|
  Capybara::Playwright::Driver.new(
    app,
    **PLAWRIGHT_OPTS,
    headless: false
  )
end

RSpec.configure do |config|
  config.before(:each, type: :feature) do
    driver = Capybara.current_session.driver
    next unless driver.respond_to?(:with_playwright_page)

    driver.with_playwright_page do |pw|
      pw.route(
        "**/*",
        lambda { |route, request|
          sleep 2 if ENV["RAILS_TEST_LAGGY"].present?
          route.continue
        }
      )
    end
  end
end
