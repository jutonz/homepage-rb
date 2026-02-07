module Plants
  class PlantImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def new
      @plant = find_plant
      @plant_image = authorize(@plant.plant_images.new)
    end

    def create
      @plant = find_plant
      @plant_image = authorize(@plant.plant_images.new(plant_image_params))

      if @plant_image.save
        redirect_to(plant_path(@plant), notice: "Image was added.")
      else
        flash.now[:alert] =
          @plant_image.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_content)
      end
    end

    def show
      @plant = find_plant
      @plant_image = authorize(find_plant_image)
    end

    def edit
      @plant = find_plant
      @plant_image = authorize(find_plant_image)
    end

    def update
      @plant = find_plant
      @plant_image = authorize(find_plant_image)

      if @plant_image.update(plant_image_update_params)
        redirect_to(
          plant_plant_image_path(@plant, @plant_image),
          notice: "Image was updated."
        )
      else
        flash.now[:alert] =
          @plant_image.errors.full_messages.to_sentence
        render(:edit, status: :unprocessable_content)
      end
    end

    def destroy
      @plant = find_plant
      @plant_image = authorize(find_plant_image)
      @plant_image.destroy!
      redirect_to(plant_path(@plant), notice: "Image was deleted.")
    end

    private

    def find_plant
      policy_scope(Plants::Plant).find(params[:plant_id])
    end

    def find_plant_image
      policy_scope(Plants::PlantImage)
        .where(plant: @plant)
        .find(params[:id])
    end

    def plant_image_params
      params.expect(plants_plant_image: %i[file taken_at])
    end

    def plant_image_update_params
      params.expect(plants_plant_image: [:taken_at])
    end
  end
end
