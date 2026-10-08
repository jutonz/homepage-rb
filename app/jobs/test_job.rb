# typed: strict

class TestJob < ApplicationJob
  queue_as :background

  sig { void }
  def perform
    Rails.logger.info "hi"
  end
end
