# typed: true
# frozen_string_literal: true

# `prometheus_exporter` is `require: false` in the Gemfile, so
# `Bundler.require` never loads it and Tapioca cannot reflect on its
# constants. Require the entry points the app actually uses.
require "prometheus_exporter"
require "prometheus_exporter/client"
require "prometheus_exporter/middleware"
