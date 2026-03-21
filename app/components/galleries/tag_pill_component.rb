module Galleries
  class TagPillComponent < ApplicationComponent
    erb_template <<~ERB
      <%= render(PillComponent.new(
        text: @tag.display_name,
        color: :gray
      )) %>
    ERB

    def initialize(tag:)
      @tag = tag
    end
  end
end
