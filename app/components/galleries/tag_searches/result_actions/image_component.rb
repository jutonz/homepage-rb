# typed: true

module Galleries
  module TagSearches
    module ResultActions
      class ImageComponent < BaseComponent
        sig { override.returns(String) }
        def call
          helpers.button_to(
            "Add tag",
            gallery_image_tags_path(gallery, tag_search.image, tag_id: tag.id),
            class: "button"
          )
        end
      end
    end
  end
end
