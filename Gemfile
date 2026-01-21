source "https://rubygems.org"

ruby file: ".tool-versions"

# remove after this is the ruby default version
gem "openssl", "4.0.0"

gem "after_party"
gem "aws-sdk-s3"
gem "csv"
gem "faraday"
gem "image_hash"
gem "image_processing"
gem "importmap-rails"
gem "jbuilder"
gem "jwt"
gem "kaminari"
gem "neighbor"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
gem "opentelemetry-sdk"
gem "pg", "~> 1.6"
gem "prometheus_exporter", require: false
gem "puma", ">= 5.0"
gem "pundit"
gem "rails", "~> 8.1.2"
gem "redis", ">= 4.0.1"
gem "simple_form"
gem "solid_queue"
gem "sprockets-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "view_component"
gem "warden"

# Sentry
gem "stackprof"
gem "sentry-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "brakeman", require: false
  gem "bullet"
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "simplecov", require: false
  gem "simplecov_json_formatter", require: false
  gem "standard"
end

group :development do
  gem "annotaterb"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "super_diff"
  gem "webmock"
end

gem "solid_cable", "~> 3.0"
