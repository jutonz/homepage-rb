# typed: true

module Galleries
  module TagSearches
    module ResultActions
      class BulkUploadTagComponent < BaseComponent
        sig { override.returns(String) }
        def call
          helpers.button_to(
            "Add tag",
            gallery_bulk_upload_tags_path(
              gallery, tag_id: tag.id
            ),
            class: "button"
          )
        end
      end
    end
  end
end
