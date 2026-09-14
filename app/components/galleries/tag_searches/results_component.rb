# typed: true

module Galleries
  module TagSearches
    class ResultsComponent < ApplicationComponent
      MODE_ACTIONS = T.let(
        {
          image: ResultActions::ImageComponent,
          gallery: ResultActions::GalleryComponent,
          bulk_upload_tag: ResultActions::BulkUploadTagComponent,
          bulk_add_tag: ResultActions::BulkAddTagComponent,
          auto_add: ResultActions::AutoAddComponent
        }.freeze,
        T::Hash[Symbol, T.class_of(ResultActions::BaseComponent)]
      )
      private_constant(:MODE_ACTIONS)

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
                <%= render(search_result_action(tag:)) %>
              </div>
            <% end %>
          <% end %>
        <% end %>
      ERB

      sig do
        params(
          tag_search: Galleries::TagSearch,
          mode: Symbol,
          turbo_frame_tag: String
        ).void
      end
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

      sig { returns(Symbol) }
      attr_reader :mode

      sig { params(tag: Galleries::Tag).returns(ResultActions::BaseComponent) }
      def search_result_action(tag:)
        MODE_ACTIONS.fetch(mode) {
          raise(ArgumentError, "unknown tag search mode: #{mode.inspect}")
        }.new(tag_search: @tag_search, tag:)
      end
    end
  end
end
