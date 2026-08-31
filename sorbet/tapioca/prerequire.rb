# typed: false
# frozen_string_literal: true

# Tapioca runs `Bundler.require` before the Rails app initializes, so
# ActiveRecord::Base.configurations is empty when solid_queue/solid_cable
# models call `connects_to` at class-definition time. Seed placeholder
# configs so those requires resolve without a real connection.
require "active_record"

ActiveRecord::Base.configurations = {
  "development" => {
    "primary" => {"adapter" => "postgresql"},
    "queue" => {"adapter" => "postgresql"},
    "cable" => {"adapter" => "postgresql"}
  }
}
