module Plants
  class PlantImageComponent < ApplicationComponent
    erb_template <<~ERB
      <div
        class="border border-gray-200 rounded-md p-2"
        data-image-id="<%= @plant_image.id %>"
      >
        <div class="flex justify-center mb-2">
          <%= link_to(plant_plant_image_path(@plant, @plant_image)) do %>
            <%= image_tag(@plant_image.file, loading: "lazy") %>
          <% end %>
        </div>
        <% if @plant_image.taken_at.present? %>
          <div class="text-xs text-gray-600 mb-2">
            Taken: <%= @plant_image.taken_at.to_date %>
          </div>
        <% end %>
      </div>
    ERB

    def initialize(plant_image:)
      @plant_image = plant_image
      @plant = plant_image.plant
    end
  end
end
