# typed: true

require_relative "extractor"
require_relative "template_path"

module ErbCallSites
  # Keeps the generated transcriptions under `output` in step with the ERB
  # templates under `sources`. The transcriptions are committed so that the
  # existing `bin/srb tc` step checks them without a second Sorbet run;
  # `stale` is what stops them drifting away from the templates.
  class Generator
    # Raised rather than letting one template's transcription silently
    # overwrite another's, which would leave `stale` unable to settle.
    class CollidingTemplates < StandardError; end

    # Deliberately one directory for now: HPRB-38 set out to establish what
    # this catches before paying for it across all of app/views.
    SOURCES = ["app/views/todo"].freeze

    OUTPUT = "sorbet/erb_call_sites"

    sig { params(root: Pathname).returns(Generator) }
    def self.pilot(root:)
      new(root:, sources: SOURCES, output: OUTPUT)
    end

    sig do
      params(
        root: Pathname,
        sources: T::Array[String],
        output: String
      ).void
    end
    def initialize(root:, sources:, output:)
      @root = root
      @sources = sources
      @output = output
    end

    sig { void }
    def generate
      transcriptions.each do |path, contents|
        full = root.join(path)
        FileUtils.mkdir_p(full.dirname)
        full.write(contents)
      end

      orphans.each { root.join(it).delete }
    end

    # Paths whose committed contents no longer match the templates, plus
    # transcriptions left behind by templates that have gone away.
    sig { returns(T::Array[String]) }
    def stale
      outdated = transcriptions.reject { |path, contents|
        full = root.join(path)
        full.exist? && full.read == contents
      }.keys

      (outdated + orphans).sort
    end

    private

    attr_reader :root, :sources, :output

    sig { returns(T::Hash[String, String]) }
    def transcriptions
      pairs = templates.filter_map do |template|
        extractor = Extractor.new(
          template: root.join(template).read,
          source_path: template
        )

        [transcription_path(template), extractor.to_ruby] if
          extractor.call_sites?
      end

      guard_collisions(pairs)
      pairs.to_h
    end

    sig { params(pairs: T::Array[T.untyped]).void }
    def guard_collisions(pairs)
      colliding = pairs.map(&:first).tally.select { |_, count| count > 1 }
      return if colliding.empty?

      raise(
        CollidingTemplates,
        "More than one template maps to #{colliding.keys.sort.join(", ")}"
      )
    end

    sig { returns(T::Array[String]) }
    def templates
      sources.flat_map { |source|
        Dir.glob(root.join(source, "**/*.erb")).sort
      }.map { Pathname.new(it).relative_path_from(root).to_s }
    end

    sig { params(template: String).returns(String) }
    def transcription_path(template)
      File.join(output, TemplatePath.new(template).relative_path)
    end

    sig { returns(T::Array[String]) }
    def orphans
      wanted = transcriptions.keys

      Dir.glob(root.join(output, "**/*.rb"))
        .map { Pathname.new(it).relative_path_from(root).to_s }
        .reject { wanted.include?(it) }
        .sort
    end
  end
end
