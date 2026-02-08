module Plants
  class PlantImageUpload
    Result = Struct.new(:saved, :plant_image, keyword_init: true) do
      def saved?
        saved
      end
    end

    def initialize(plant:, files:, taken_at:)
      @plant = plant
      @files = files
      @taken_at = taken_at
    end

    def save
      files = Array(@files).reject(&:blank?)
      return missing_file_result if files.empty?

      create_images(files)
    end

    private

    def missing_file_result
      plant_image = @plant.plant_images.new(taken_at: @taken_at)
      plant_image.validate
      Result.new(saved: false, plant_image:)
    end

    def create_images(files)
      saved = true
      plant_image = nil

      Plants::PlantImage.transaction do
        files.each do |file|
          current = @plant.plant_images.new(file:, taken_at: @taken_at)
          next if current.save

          plant_image = current
          saved = false
          raise ActiveRecord::Rollback
        end
      end

      return Result.new(saved: true) if saved

      Result.new(saved: false, plant_image:)
    end
  end
end
