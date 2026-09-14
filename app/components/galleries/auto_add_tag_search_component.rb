# typed: true

module Galleries
  class AutoAddTagSearchComponent < ApplicationComponent
    erb_template <<~ERB
      <div data-controller="tag-search">
        <%= render(Galleries::TagSearches::FormComponent.new(
          tag_search: @tag_search,
          search_path: gallery_tag_search_path(@gallery),
          extra_search_params: {
            mode: "auto_add",
            auto_add_source_id: @auto_add_source.id
          }
        )) %>

        <div data-tag-search-target="results">
          <%= render(Galleries::TagSearches::ResultsComponent.new(
            tag_search: @tag_search,
            mode: :auto_add
          )) %>
        </div>
      </div>
    ERB

    sig { params(tag_search: Galleries::TagSearch).void }
    def initialize(tag_search:)
      @tag_search = tag_search
      @gallery = tag_search.gallery
      @auto_add_source = tag_search.auto_add_source
    end
  end
end
