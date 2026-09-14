# typed: strict

module Plants
  class PlantsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def index
      authorize(Plants::Plant)
      @plants = T.let(
        Plants::PlantPolicy.scope_for(current_user)
          .includes(key_image: :file_attachment)
          .order(:name),
        T.nilable(T.all(ActiveRecord::Relation, T::Enumerable[Plants::Plant]))
      )
    end

    sig { void }
    def new
      @plant = T.let(
        authorize(current_user.plants.new),
        T.nilable(Plants::Plant)
      )
    end

    sig { void }
    def create
      @plant = authorize(
        T.let(current_user.plants.new(plant_params), Plants::Plant)
      )

      if @plant.save
        redirect_to(plant_path(@plant), notice: "Plant was created.")
      else
        render(:new, status: :unprocessable_content)
      end
    end

    sig { void }
    def show
      @plant = authorize(Plants::Plant.find(params[:id]))
      @plant_images = T.let(
        @plant
          .plant_images
          .includes(file_attachment: :blob)
          .order(taken_at: :desc),
        T.nilable(
          T.all(ActiveRecord::Relation, T::Enumerable[Plants::PlantImage])
        )
      )
    end

    sig { void }
    def edit
      @plant = authorize(Plants::Plant.find(params[:id]))
    end

    sig { void }
    def update
      @plant = authorize(Plants::Plant.find(params[:id]))

      if @plant.update(plant_params)
        redirect_to(plant_path(@plant), notice: "Plant was updated.")
      else
        render(:edit, status: :unprocessable_content)
      end
    end

    sig { void }
    def destroy
      @plant = authorize(Plants::Plant.find(params[:id]))
      @plant.destroy!
      redirect_to(plants_path, notice: "Plant was deleted.")
    end

    private

    sig { returns(ActionController::Parameters) }
    def plant_params
      params.expect(
        plants_plant: %i[
          name purchased_at purchased_from died_at notes
        ]
      )
    end
  end
end
