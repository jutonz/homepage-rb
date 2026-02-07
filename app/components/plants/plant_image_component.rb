module Plants
  class PlantImageComponent < ApplicationComponent
    erb_template <<~ERB
      <div class="border border-gray-200 rounded-md p-2">
        <div class="flex justify-center mb-2">
          <%= image_tag(@plant_image.file().variant(:thumb)) %>
        </div>
        <% if @plant_image.taken_at().present?() %>
          <div class="text-xs text-gray-600 mb-2">
            Taken: <%= @plant_image.taken_at().to_date() %>
          </div>
        <% end %>
        <div>
          <%= button_to(
            "Delete",
            plant_plant_image_path(@plant, @plant_image),
            method: :delete,
            data: {turbo_confirm: "Are you sure?"},
            class: "button button--danger w-full"
          ) %>
        </div>
      </div>
    ERB

    def initialize(plant_image:)
      @plant_image = plant_image
      @plant = plant_image.plant()
    end
  end
end
