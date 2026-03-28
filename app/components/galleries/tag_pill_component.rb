module Galleries
  class TagPillComponent < ApplicationComponent
    CLASSIFICATION_COLORS = {
      "none" => :gray,
      "subject" => :purple,
      "system" => :red
    }.freeze

    renders_many :actions

    erb_template <<~ERB
      <% display_name_html = link_to(
        @tag.display_name,
        gallery_tag_path(@tag.gallery, @tag),
        data: {turbo: false, role: "tag-link"}
      ) %>

      <%= render(PillComponent.new(
        text: display_name_html,
        color: @color,
        class_name: "gap-3"
      )) do |pill|%>
        <% actions.each do |action| %>
          <% pill.with_action { action.to_s.html_safe } %>
        <% end %>
      <% end %>
    ERB

    def initialize(tag:)
      @tag = tag
      @color = CLASSIFICATION_COLORS.fetch(tag.classification, :gray)
    end
  end
end
