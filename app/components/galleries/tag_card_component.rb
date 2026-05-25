module Galleries
  class TagCardComponent < ApplicationComponent
    CLASSIFICATION_CARD_CLASSES = {
      "none" =>
        "border-gray-200 hover:bg-gray-50 hover:border-gray-300",
      "subject" =>
        "bg-purple-50 border-purple-200 " \
        "hover:bg-purple-100 hover:border-purple-300",
      "system" =>
        "bg-red-50 border-red-200 " \
        "hover:bg-red-100 hover:border-red-300",
      "artist" =>
        "bg-teal-50 border-teal-200 " \
        "hover:bg-teal-100 hover:border-teal-300"
    }.freeze

    erb_template <<~ERB
      <%= link_to(
        gallery_tag_path(@tag.gallery, @tag),
        data: {role: "tag"},
        class: @card_classes
      ) do %>
        <div class="flex justify-between items-center">
          <div class="flex items-center gap-2">
            <span class="font-medium text-gray-900 group-hover:text-gray-700"><%= @tag.name %></span>
            <%= render(
              Galleries::TagClassificationPillComponent.new(tag: @tag)
            ) %>
          </div>
          <span class="text-sm text-gray-500 bg-gray-100 px-2 py-1 rounded-full"><%= @tag.image_tags_count %></span>
        </div>
      <% end %>
    ERB

    def initialize(tag:)
      @tag = tag
      @card_classes = card_classes_for(tag.classification)
    end

    private

    def card_classes_for(classification)
      base = "block p-4 border rounded-lg " \
        "transition-colors duration-200 group"
      variant = CLASSIFICATION_CARD_CLASSES.fetch(
        classification,
        CLASSIFICATION_CARD_CLASSES.fetch("none")
      )
      "#{base} #{variant}"
    end
  end
end
