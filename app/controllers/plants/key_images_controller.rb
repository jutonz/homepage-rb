module Plants
  class KeyImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def update
      @plant = authorize(find_plant)
      @plant_image = find_plant_image

      if @plant.update(key_image: @plant_image)
        redirect_to(
          plant_plant_image_path(@plant, @plant_image),
          notice: "Key image was updated."
        )
      else
        redirect_to(
          plant_plant_image_path(@plant, @plant_image),
          alert: @plant.errors.full_messages.to_sentence
        )
      end
    end

    private

    def find_plant
      policy_scope(Plants::Plant).find(params[:plant_id])
    end

    def find_plant_image
      @plant.plant_images.find(params.expect(:key_image_id))
    end
  end
end
