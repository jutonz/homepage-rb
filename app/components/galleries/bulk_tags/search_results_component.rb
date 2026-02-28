module Galleries
  module BulkTags
    class SearchResultsComponent < ApplicationComponent
      def initialize(tag_search:)
        @tag_search = tag_search
      end

      erb_template <<~ERB
        <%= turbo_frame_tag("bulk-tag-search-results") do %>
          <% Array(@tag_search.results).each do |tag| %>
            <div class="my-2">
              <button
                type="button"
                class="button"
                data-action="gallery-bulk-tag#selectTag"
                data-tag-id="<%= tag.id %>"
                data-tag-name="<%= tag.display_name %>"
              >
                <%= tag.display_name %>
              </button>
            </div>
          <% end %>
        <% end %>
      ERB
    end
  end
end
