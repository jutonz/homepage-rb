module Plants
  class KeyImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def edit
      @plant = authorize(find_plant)
      @plant_images = plant_images
    end

    def update
      @plant = authorize(find_plant)
      @plant_image = find_plant_image

      if @plant.update(key_image: @plant_image)
        redirect_to(plant_path(@plant), notice: "Key image was updated.")
      else
        flash.now[:alert] = @plant.errors.full_messages.to_sentence
        @plant_images = plant_images
        render(:edit, status: :unprocessable_content)
      end
    end

    private

    def find_plant
      policy_scope(Plants::Plant).find(params[:plant_id])
    end

    def find_plant_image
      @plant.plant_images.find(params.expect(:key_image_id))
    end

    def plant_images
      @plant
        .plant_images
        .includes(:file_attachment)
        .order(taken_at: :desc)
    end
  end
end
