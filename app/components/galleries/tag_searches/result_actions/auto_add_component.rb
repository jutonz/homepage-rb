# typed: true

module Galleries
  module TagSearches
    module ResultActions
      class AutoAddComponent < BaseComponent
        sig { override.returns(String) }
        def call
          helpers.button_to(
            "Add",
            gallery_tag_auto_add_tags_path(
              gallery,
              tag_search.auto_add_source,
              auto_add_tag: {auto_add_tag_id: tag.id}
            ),
            class: "button",
            form: {data: {turbo_frame: "_top"}}
          )
        end
      end
    end
  end
end
