module Galleries
  module TagSearches
    class ResultsComponent < ApplicationComponent
      erb_template <<~ERB
        <%= turbo_frame_tag("tag-search-results") do %>
          <% if @tag_search.query.present? %>
            <%= helpers.simple_form_for(
              [@gallery, Galleries::Tag.new(name: @tag_search.query)],
              html: {
                data: {turbo: false}
              },
              url: gallery_tags_path(@gallery, add_to_image_id: @image.id)
            ) do |f| %>
              <%= f.input(:name, as: :hidden) %>
              <%= f.button(
                :submit,
                "Create tag '\#{@tag_search.query}'",
                class: "mt-3"
              ) %>
            <% end %>
          <% end %>

          <% Array(@tag_search.results).each do |tag| %>
            <%= turbo_frame_tag("tag-search-result-\#{tag.id}") do %>
              <div class="flex gap-4 my-2" data-role="tag-search-result">
                <%= link_to(
                  tag.display_name,
                  gallery_tag_path(tag.gallery, tag),
                  data: {turbo: false}
                ) %>
                <%= button_to(
                  "Add tag",
                  gallery_image_tags_path(@gallery, @image, tag_id: tag.id),
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
    end
  end
end
