module Galleries
  module TagSearches
    class RelatedTagsBoxComponent < ApplicationComponent
      erb_template <<~ERB
        <div
          class="border border-gray-200 rounded-lg p-4 my-2"
          data-controller="related-tags-box"
          data-role="related-tags-box"
        >
          <div class="flex justify-between items-center">
            <h4 class="text-md">Related to "<%= @tag.name %>"</h4>
            <button
              type="button"
              aria-label="Dismiss related tags"
              class="opacity-60 hover:opacity-100 cursor-pointer"
              data-action="related-tags-box#dismiss"
            >×</button>
          </div>

          <hr class="my-3 border-gray-200">

          <div class="space-y-2">
            <% @related_tags.each do |related| %>
              <div
                id="related-suggestion-<%= related.tag.id %>"
                class="flex items-center gap-3"
              >
                <%= render(
                  Galleries::TagPillComponent.new(tag: related.tag)
                ) %>
                <span class="text-xs text-gray-500">
                  <%= related.shared_count %> shared
                </span>
                <%= helpers.button_to(
                  "Add tag",
                  gallery_image_tags_path(
                    @gallery,
                    @image,
                    tag_id: related.tag.id,
                    from_related: true
                  ),
                  class: "button button--small ml-auto"
                ) %>
              </div>
            <% end %>
          </div>
        </div>
      ERB

      def initialize(tag:, image:, related_tags:)
        @tag = tag
        @image = image
        @gallery = image.gallery
        @related_tags = related_tags
      end
    end
  end
end
