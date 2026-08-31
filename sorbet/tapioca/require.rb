# typed: true
# frozen_string_literal: true

# Files that `Bundler.require` does not load on its own, so Tapioca
# cannot reflect on the constants they define.

# `prometheus_exporter` is `require: false` in the Gemfile.
require "prometheus_exporter"
require "prometheus_exporter/client"
require "prometheus_exporter/middleware"

# Test helpers are required by the suite rather than on gem load, so
# without these the generated RBIs omit the constants spec/rails_helper
# mixes in.
require "capybara/rspec/matchers"
require "view_component/test_helpers"
require "view_component/system_test_helpers"
