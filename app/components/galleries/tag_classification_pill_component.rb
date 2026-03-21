module Galleries
  class TagClassificationPillComponent < ApplicationComponent
    erb_template <<~ERB
      <% unless @tag.classification_none? %>
        <span data-role="classification">
          <%= render(PillComponent.new(
            text: @tag.classification,
            color: Galleries::TagPillComponent::CLASSIFICATION_COLORS.fetch(
              @tag.classification,
              :gray
            )
          )) %>
        </span>
      <% end %>
    ERB

    def initialize(tag:)
      @tag = tag
    end
  end
end
