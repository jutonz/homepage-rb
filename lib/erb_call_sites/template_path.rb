# typed: true

module ErbCallSites
  # Where one template's transcription lives and what its class is called.
  # Both the extractor and the generator need this mapping, and they have
  # to agree on it, so it lives in one place.
  class TemplatePath
    VIEW_ROOT = "app/views/"
    private_constant :VIEW_ROOT

    sig { params(source_path: String).void }
    def initialize(source_path)
      @source_path = source_path
    end

    sig { returns(String) }
    def class_name = stem.tr("/.", "__").camelize

    sig { returns(String) }
    def relative_path = "#{stem}.rb"

    private

    attr_reader :source_path

    # The template path with the view root, the `.erb`, and a partial's
    # leading underscore removed. A non-html format is kept, so that
    # show.html.erb and show.turbo_stream.erb do not collide.
    sig { returns(String) }
    def stem
      relative = source_path
        .delete_prefix(VIEW_ROOT)
        .delete_suffix(".erb")
        .delete_suffix(".html")

      directory, _, name = relative.rpartition("/")

      File.join(directory, name.delete_prefix("_"))
    end
  end
end
