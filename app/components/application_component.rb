class ApplicationComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers
  include Turbo::FramesHelper
end
