module Galleries
  class RelatedTagsComponent < ApplicationComponent
    erb_template <<~ERB
      <% if @related_tags.any? %>
        <div class="mb-6" data-role="related-tags">
          <%= render(CardComponent.new(title: "Related tags")) do |c| %>
            <% c.with_body do %>
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
            <% end %>
          <% end %>
        </div>
      <% end %>
    ERB

    def initialize(related_tags:)
      @related_tags = related_tags
    end
  end
end
