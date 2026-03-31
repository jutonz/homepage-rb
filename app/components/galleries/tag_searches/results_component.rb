module Galleries
  module TagSearches
    class ResultsComponent < ApplicationComponent
      erb_template <<~ERB
        <%= turbo_frame_tag(@_turbo_frame_tag) do %>
          <% if @image && @tag_search.query.present? %>
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
                <%= render(Galleries::TagPillComponent.new(tag:)) %>
                <%= search_result_action(tag:) %>
              </div>
            <% end %>
          <% end %>
        <% end %>
      ERB

      def initialize(
        tag_search:,
        mode: :image,
        turbo_frame_tag: "tag-search-results"
      )
        @tag_search = tag_search
        @gallery = tag_search.gallery
        @image = tag_search.image
        @mode = mode
        @_turbo_frame_tag = turbo_frame_tag
      end

      private

      attr_reader :mode

      def search_result_action(tag:)
        if mode == :image
          helpers.button_to(
            "Add tag",
            gallery_image_tags_path(@gallery, @image, tag_id: tag.id),
            class: "button"
          )
        elsif mode == :gallery
          existing_tag_ids = Array(helpers.request.query_parameters[:tag_ids])
          return if existing_tag_ids.include?(tag.id.to_s)

          helpers.link_to(
            "Add",
            gallery_path(
              @gallery,
              **helpers.request.query_parameters.merge(
                tag_ids: existing_tag_ids + [tag.id.to_s]
              )
            ),
            class: "button",
            data: {turbo: false}
          )
        elsif mode == :bulk_upload_tag
          helpers.button_to(
            "Add tag",
            gallery_bulk_upload_tags_path(
              @gallery, tag_id: tag.id
            ),
            class: "button"
          )
        elsif mode == :bulk_add_tag
          content_tag(
            :button,
            type: "button",
            class: "button",
            data: {
              action: "gallery-bulk-tag#selectTag",
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
