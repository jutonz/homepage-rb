module Galleries
  module Images
    class RecentTagsComponent < ApplicationComponent
      erb_template <<~ERB
        <%= turbo_frame_tag("image-recent-tags") do %>
          <h4 class="text-xl mt-10">Recently used tags</h4>
          <% grouped_tags.each_with_index do |(image_id, results), index| %>
            <% if index > 0 %>
              <hr class="my-4 border-gray-300" data-testid="tag-group-separator">
            <% end %>
            <div class="flex flex-wrap gap-2 my-2">
              <% results.each do |result| %>
                <%= turbo_frame_tag("recently-added-tag-\#{result.tag.id}") do %>
                  <%= button_to(
                    result.tag.display_name,
                    gallery_image_tags_path(@gallery, @image, tag_id: result.tag.id),
                    class: "button"
                  ) %>
                <% end %>
              <% end %>
            </div>
          <% end %>
        <% end %>
      ERB

      def initialize(gallery:, image:)
        @gallery = gallery
        @image = image
      end

      private

      def grouped_tags
        @gallery
          .recently_used_tags(excluded_image_ids: [@image.id])
          .group_by(&:most_recent_image_id)
      end
    end
  end
end
