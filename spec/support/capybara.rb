require "capybara/playwright"

Capybara.enable_aria_label = true

playwright_cli_version = Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip
playwright_cli_executable_path =
  "npm exec --no playwright@#{playwright_cli_version}"
PLAYWRIGHT_OPTS = {
  playwright_cli_executable_path:,
  browser_type: :chromium,
  viewport: {width: 1400, height: 900}
}.freeze

# When node_modules holds a Playwright version that the gem does not expect,
# the gem fails with an unrelated protocol error, such as
# "timeout: expected float, got undefined".
def verify_installed_playwright!(expected_version)
  package_json = Rails.root.join("node_modules/playwright/package.json")
  installed_version =
    package_json.exist? ? JSON.parse(package_json.read)["version"] : "none"
  return if installed_version == expected_version

  raise <<~MESSAGE
    System specs need npm playwright #{expected_version}, but node_modules
    has #{installed_version}. Run:
      npm ci && npm exec --no -- playwright install chromium
  MESSAGE
end

# driven_by re-registers a driver named :playwright with Rails' own options,
# which discards PLAYWRIGHT_OPTS. Rails leaves other driver names alone.
Capybara.register_driver(:playwright_headless) do |app|
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

def playwright = page.driver.with_playwright_page { it }

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    verify_installed_playwright!(playwright_cli_version)
    driven_by(:playwright_headless)
  end

  config.before(:each, type: :system, debug: true) do
    verify_installed_playwright!(playwright_cli_version)
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

      if ENV["RAILS_TEST_SLOW_JS"].present?
        cdp = pw.context.new_cdp_session(pw)
        cdp.send_message(
          "Emulation.setCPUThrottlingRate",
          params: {rate: 100}
        )
      end
    end
  end
end
