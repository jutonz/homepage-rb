module Galleries
  class TagPillComponent < ApplicationComponent
    CLASSIFICATION_COLORS = {
      "none" => :gray,
      "subject" => :purple
    }.freeze

    erb_template <<~ERB
      <%= render(PillComponent.new(
        text: @tag.display_name,
        color: @color
      )) %>
    ERB

    def initialize(tag:)
      @tag = tag
      @color = CLASSIFICATION_COLORS.fetch(
        tag.classification,
        :gray
      )
    end
  end
end
