require "capybara/playwright"

Capybara.enable_aria_label = true

playwright_cli_version = Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip
playwright_cli_executable_path =
  "npx --yes playwright@#{playwright_cli_version}"
PLAYWRIGHT_OPTS = {
  playwright_cli_executable_path:,
  browser_type: :chromium,
  viewport: {width: 1400, height: 900}
}.freeze

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    **PLAYWRIGHT_OPTS,
    headless: true
  )
end

Capybara.register_driver(:playwright_debug) do |app|
  Capybara::Playwright::Driver.new(
    app,
    **PLAYWRIGHT_OPTS,
    headless: false
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    driven_by(:playwright)
  end

  config.before(:each, type: :system, debug: true) do
    driven_by(:playwright_debug)
  end

  config.before(:each, type: :system) do
    driver = Capybara.current_session.driver
    next unless driver.respond_to?(:with_playwright_page)

    driver.with_playwright_page do |pw|
      pw.route(
        "**/*",
        lambda { |route, request|
          sleep 1 if ENV["RAILS_TEST_LAGGY"].present?
          route.continue
        }
      )
    end
  end
end
