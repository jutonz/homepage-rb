require "capybara/playwright"

playwright_cli_version = Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip
playwright_cli_executable_path =
  "npx playwright@#{playwright_cli_version}"
PLAWRIGHT_OPTS = {
  playwright_cli_executable_path:,
  browser_type: :chromium
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
