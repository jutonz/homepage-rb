class TestJob < ApplicationJob
  queue_as :background

  def perform
    Rails.logger.info "hi"
  end
end
