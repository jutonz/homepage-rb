module Galleries
  class TaggingNeededJob < ApplicationJob
    queue_as :background

    def perform
      Gallery.find_each { apply_tagging_needed(_1) }
    end

    private

    def apply_tagging_needed(gallery)
      tag = Galleries::Tag.tagging_needed(gallery)

      gallery
        .images
        .where.missing(:tags)
        .find_each { _1.add_tag(tag) }
    end
  end
end