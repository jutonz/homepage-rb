# typed: true

module Galleries
  module TagSearches
    module ResultActions
      class BulkAddTagComponent < BaseComponent
        sig { override.returns(String) }
        def call
          content_tag(
            :button,
            type: "button",
            class: "button",
            data: {
              action: [
                "gallery-bulk-tag#selectTag",
                "tag-search#clearQuery"
              ].join(" "),
              tag_id: tag.id,
              tag_name: tag.display_name
            }
          ) do
            "Select"
          end
        end
      end
    end
  end
end
