module Galleries
  class ImageTagSearchComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers
    include Turbo::FramesHelper

    erb_template <<~ERB
      <h3 class="text-lg mb-3">Add tag</h3>

      <%= render(Galleries::TagSearches::FormComponent.new(
        tag_search: @tag_search
      )) %>

      <%= render(
        partial: "galleries/images/tag_searches/results",
        locals: {
          tag_search: @tag_search,
          gallery: @gallery,
          image: @image
        }
      ) %>
    ERB

    def initialize(tag_search:)
      @tag_search = tag_search
      @gallery = tag_search.gallery
      @image = tag_search.image
    end
  end
end
