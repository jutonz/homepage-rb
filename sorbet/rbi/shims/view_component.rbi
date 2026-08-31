# typed: strong

# ViewComponent implements its inline-template DSL through
# `method_missing` on ViewComponent::InlineTemplate::ClassMethods, which
# accepts any class method ending in `_template` (see the gem's
# lib/view_component/inline_template.rb). Because no real method is ever
# defined, Tapioca cannot reflect on it and the generated gem RBI omits
# it entirely.
#
# ViewComponent::Base extends this module, so declaring `erb_template`
# here covers ApplicationComponent and every component beneath it.
module ViewComponent::InlineTemplate::ClassMethods
  sig { params(source: ::String).void }
  def erb_template(source); end
end
