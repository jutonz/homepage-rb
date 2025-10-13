module Galleries
  class ImageTagSearchComponent < ApplicationComponent
    erb_template <<~ERB
      <h3 class="text-lg mb-3">Add tag</h3>

      <%= render(Galleries::TagSearches::FormComponent.new(
        tag_search: @tag_search
      )) %>

      <%= render(Galleries::TagSearches::ResultsComponent.new(
        tag_search: @tag_search
      )) %>

      <h4 class="text-md mt-10">Recently used tags</h4>
      <% grouped_tags.each_with_index do |(image_id, results), index| %>
        <% if index > 0 %>
          <hr class="my-4 border-gray-300" data-testid="tag-group-separator">
        <% end %>
        <% results.each do |result| %>
          <%= turbo_frame_tag("recently-added-tag-\#{result.tag.id}") do %>
            <div class="flex gap-4 my-2">
              <%= result.tag.display_name %>
              <%= button_to(
                "Add tag",
                gallery_image_tags_path(@gallery, @image, tag_id: result.tag.id),
                class: "button"
              ) %>
            </div>
          <% end %>
        <% end %>
      <% end %>
    ERB

    def initialize(tag_search:)
      @tag_search = tag_search
      @gallery = tag_search.gallery
      @image = tag_search.image
    end

    private

    def grouped_tags
      @gallery
        .recently_used_tags(excluded_image_ids: [@image.id])
        .group_by(&:most_recent_image_id)
    end
  end
end
