source "https://rubygems.org"

ruby "3.4.1"

gem "after_party"
gem "annotate", "~> 3.2"
gem "aws-sdk-s3"
gem "faraday"
gem "image_processing"
gem "importmap-rails"
gem "jbuilder"
gem "jwt"
gem "kaminari"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "rails", "~> 7.2.2"
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
gem "sentry-ruby"
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
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "standard"
  gem "brakeman", require: false
end

group :development do
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
