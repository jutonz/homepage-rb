class ApplicationComponent < ViewComponent::Base
  # Sorbet requires ancestors to be constant literals; this mixin is
  # built at runtime. See sorbet/rbi/shims/application_component.rbi.
  T.unsafe(self).include Rails.application.routes.url_helpers
  include Turbo::FramesHelper
end
