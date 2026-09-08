# Transcribes the ViewComponent constructions in ERB templates into Ruby
# that Sorbet checks, so that a wrong argument in a template is caught by
# `bin/srb tc` rather than at render time. The transcriptions are committed
# under sorbet/erb_call_sites; `verify` is what keeps them honest.
#
# See docs/adr/0001-erb-call-site-typing.md for what this catches and
# what it still cannot.
namespace :erb_call_sites do
  def erb_call_sites_generator
    require Rails.root.join("lib/erb_call_sites/generator").to_s

    ErbCallSites::Generator.pilot(root: Rails.root)
  end

  desc "Regenerate the Sorbet transcriptions of ERB component call sites"
  task generate: :environment do
    generator = erb_call_sites_generator
    generator.generate
    puts("Wrote #{ErbCallSites::Generator::OUTPUT} from " \
         "#{ErbCallSites::Generator::SOURCES.join(", ")}")
  end

  desc "Check the ERB call site transcriptions are up to date"
  task verify: :environment do
    stale = erb_call_sites_generator.stale
    next puts("ERB call site transcriptions are up to date.") if stale.empty?

    warn("Out of date; run `bin/rake erb_call_sites:generate`, then read")
    warn("what `bin/srb tc` says -- if a template picked up a wrong")
    warn("argument, the type error only appears once these are rebuilt.")
    stale.each { warn("  #{it}") }
    exit(1)
  end
end
