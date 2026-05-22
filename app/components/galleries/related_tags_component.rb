module Galleries
  class RelatedTagsComponent < ApplicationComponent
    erb_template <<~ERB
      <% if @related_tags.any? %>
        <div class="mb-6" data-role="related-tags">
          <h2 class="text-xl mb-4">Related tags</h2>
          <div class="flex flex-wrap gap-2 items-center">
            <% @related_tags.each do |row| %>
              <span class="inline-flex items-center gap-1">
                <%= render(
                  Galleries::TagPillComponent.new(tag: row.tag)
                ) %>
                <span
                  class="text-xs text-gray-500"
                  data-role="related-tag-count"
                >(<%= row.shared_count %>)</span>
              </span>
            <% end %>
          </div>
        </div>
      <% end %>
    ERB

    def initialize(related_tags:)
      @related_tags = related_tags
    end
  end
end
