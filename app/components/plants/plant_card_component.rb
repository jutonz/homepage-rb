module Plants
  class PlantCardComponent < ApplicationComponent
    erb_template <<~ERB
      <div
        class="p-4 min-w-32 bg-white shadow-sm hover:shadow-md
                transition-shadow"
      >
        <% if @plant.key_image&.file&.attached? %>
          <div class="mb-2">
            <%= image_tag(
              @plant.key_image.file.variant(resize_to_limit: [320, 320]),
              loading: "lazy"
            ) %>
          </div>
        <% end %>
        <div class="font-medium"><%= @plant.name %></div>
        <% if action.present? %>
          <div class="mt-2">
            <%= action %>
          </div>
        <% end %>
      </div>
    ERB

    renders_one :action

    def initialize(plant:)
      @plant = plant
    end
  end
end
