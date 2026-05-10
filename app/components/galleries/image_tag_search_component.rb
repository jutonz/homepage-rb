module Galleries
  class ImageTagSearchComponent < ApplicationComponent
    erb_template <<~ERB
      <div data-controller="tag-search">
        <h3 class="text-lg mb-3">Add tag</h3>

        <%= render(Galleries::TagSearches::FormComponent.new(
          tag_search: @tag_search
        )) %>

        <div data-tag-search-target="results">
          <%= render(Galleries::TagSearches::ResultsComponent.new(
            tag_search: @tag_search
          )) %>
        </div>

        <%= turbo_frame_tag(
          "image-recent-tags",
          src: gallery_image_recent_tags_path(@gallery, @image),
          loading: :lazy,
          data: {controller: "refresh-on-visible"}
        ) %>
      </div>
    ERB

    def initialize(tag_search:)
      @tag_search = tag_search
      @gallery = tag_search.gallery
      @image = tag_search.image
    end
  end
end
