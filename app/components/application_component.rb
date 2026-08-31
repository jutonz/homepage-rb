# typed: true

class ApplicationComponent < ViewComponent::Base
  T.unsafe(self).include Rails.application.routes.url_helpers
  include Turbo::FramesHelper
end
