# typed: strict

module Plants
  class KeyImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def update
      plant = find_plant
      @plant = T.let(authorize(plant), T.nilable(Plants::Plant))
      plant_image = find_plant_image(plant)
      @plant_image = T.let(plant_image, T.nilable(Plants::PlantImage))

      if plant.update(key_image: plant_image)
        redirect_to(
          plant_plant_image_path(plant, plant_image),
          notice: "Key image was updated."
        )
      else
        redirect_to(
          plant_plant_image_path(plant, plant_image),
          alert: plant.errors.full_messages.to_sentence
        )
      end
    end

    private

    sig { returns(Plants::Plant) }
    def find_plant
      Plants::PlantPolicy.scope_for(current_user).find(params[:plant_id])
    end

    sig { params(plant: Plants::Plant).returns(Plants::PlantImage) }
    def find_plant_image(plant)
      plant.plant_images.find(params.expect(:key_image_id))
    end
  end
end
