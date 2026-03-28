module Galleries
  class TagPillComponent < ApplicationComponent
    CLASSIFICATION_COLORS = {
      "none" => :gray,
      "subject" => :purple
    }.freeze

    renders_many :actions

    erb_template <<~ERB
      <span class="inline-flex items-center gap-3 px-3 py-1 rounded-full
                   text-sm font-medium <%= @color_classes %>">
        <% if @link_url %>
          <%= link_to(
            @tag.display_name,
            @link_url,
            data: {turbo: false}
          ) %>
        <% else %>
          <%= @tag.display_name %>
        <% end %>
        <% actions.each do |action| %>
          <%= action %>
        <% end %>
      </span>
    ERB

    def initialize(tag:, link_url: nil)
      @tag = tag
      @link_url = link_url
      color = CLASSIFICATION_COLORS.fetch(tag.classification, :gray)
      @color_classes = PillComponent::COLOR_CLASSES.fetch(color)
    end
  end
end
