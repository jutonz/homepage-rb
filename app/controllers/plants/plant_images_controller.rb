# typed: strict

module Plants
  class PlantImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def new
      plant = find_plant
      @plant = T.let(plant, T.nilable(Plants::Plant))
      @plant_image = T.let(
        authorize(plant.plant_images.new),
        T.nilable(Plants::PlantImage)
      )
    end

    sig { void }
    def create
      @plant = find_plant
      authorize(Plants::PlantImage.new(plant: @plant))
      result = Plants::PlantImageUpload.new(
        plant: @plant,
        files: plant_image_params[:file],
        taken_at: plant_image_params[:taken_at]
      ).save

      if result.saved?
        redirect_to(plant_path(@plant), notice: "Images were added.")
        return
      end

      plant_image = T.let(result.plant_image, Plants::PlantImage)
      @plant_image = plant_image
      flash.now[:alert] = plant_image.errors.full_messages.to_sentence
      render(:new, status: :unprocessable_content)
    end

    sig { void }
    def show
      @plant = find_plant
      @plant_image = authorize(find_plant_image(@plant))
    end

    sig { void }
    def edit
      @plant = find_plant
      @plant_image = authorize(find_plant_image(@plant))
    end

    sig { void }
    def update
      @plant = find_plant
      @plant_image = authorize(find_plant_image(@plant))

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

    sig { void }
    def destroy
      @plant = find_plant
      @plant_image = authorize(find_plant_image(@plant))
      @plant_image.destroy!
      redirect_to(plant_path(@plant), notice: "Image was deleted.")
    end

    private

    sig { returns(Plants::Plant) }
    def find_plant
      Plants::PlantPolicy.scope_for(current_user).find(params[:plant_id])
    end

    sig { params(plant: Plants::Plant).returns(Plants::PlantImage) }
    def find_plant_image(plant)
      Plants::PlantImagePolicy.scope_for(current_user)
        .where(plant:)
        .find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def plant_image_params
      params.expect(plants_plant_image: [:taken_at, :file, {file: []}])
    end

    sig { returns(ActionController::Parameters) }
    def plant_image_update_params
      params.expect(plants_plant_image: [:taken_at, :notes])
    end
  end
end
