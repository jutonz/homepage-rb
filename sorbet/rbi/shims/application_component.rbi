# typed: true

# ApplicationComponent mixes in the route helpers dynamically, which
# Sorbet cannot follow, so the source uses `T.unsafe(self).include` to
# suppress srb.help/4002. That suppression also makes Sorbet ignore the
# mixin entirely, which would hide every `*_path` / `*_url` helper from
# the 19 components that call them.
#
# Declaring the mixins here restores them. This mirrors what Tapioca
# generates for ApplicationController and ApplicationMailer, which
# reach the same modules through a static include.
class ApplicationComponent
  include GeneratedUrlHelpersModule
  include GeneratedPathHelpersModule
end
