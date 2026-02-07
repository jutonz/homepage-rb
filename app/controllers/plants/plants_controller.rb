module Plants
  class PlantsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      authorize(Plants::Plant)
      @plants =
        policy_scope(Plants::Plant)
          .includes(key_image: :file_attachment)
          .order(created_at: :desc)
    end

    def new
      @plant = authorize(current_user.plants_plants.new)
    end

    def create
      @plant = authorize(current_user.plants_plants.new(plant_params))

      if @plant.save
        redirect_to(plants_path, notice: "Plant was created.")
      else
        render(:new, status: :unprocessable_content)
      end
    end

    def show
      @plant = authorize(Plants::Plant.find(params[:id]))
      @plant_images =
        @plant
          .plant_images
          .includes(:file_attachment)
          .order(taken_at: :desc)
    end

    def edit
      @plant = authorize(Plants::Plant.find(params[:id]))
    end

    def update
      @plant = authorize(Plants::Plant.find(params[:id]))

      if @plant.update(plant_params)
        redirect_to(plant_path(@plant), notice: "Plant was updated.")
      else
        render(:edit, status: :unprocessable_content)
      end
    end

    def destroy
      @plant = authorize(Plants::Plant.find(params[:id]))
      @plant.destroy!
      redirect_to(plants_path, notice: "Plant was deleted.")
    end

    private

    def plant_params
      params.expect(plants_plant: %i[name purchased_at purchased_from])
    end
  end
end
