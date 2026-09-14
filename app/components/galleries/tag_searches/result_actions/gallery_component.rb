# typed: true

module Galleries
  module TagSearches
    module ResultActions
      class GalleryComponent < BaseComponent
        sig { returns(T::Boolean) }
        def render?
          !selected_tag_ids.include?(tag.id.to_s)
        end

        sig { override.returns(String) }
        def call
          helpers.link_to(
            "Add",
            gallery_path(
              gallery,
              **helpers.request.query_parameters.merge(
                tag_ids: selected_tag_ids + [tag.id.to_s]
              )
            ),
            class: "button",
            data: {
              role: "tag-search-result-add",
              turbo_frame: "_top"
            }
          )
        end

        private

        sig { returns(T::Array[String]) }
        def selected_tag_ids
          Array(helpers.request.query_parameters[:tag_ids])
        end
      end
    end
  end
end
