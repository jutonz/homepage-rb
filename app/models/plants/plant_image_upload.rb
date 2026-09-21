# typed: strict

module Plants
  class PlantImageUpload
    Result = Struct.new(:saved, :plant_image) do
      sig { returns(T::Boolean) }
      def saved?
        saved
      end
    end

    sig do
      params(
        plant: Plants::Plant,
        files: T.untyped,
        taken_at: T.untyped
      ).void
    end
    def initialize(plant:, files:, taken_at:)
      @plant = T.let(plant, Plants::Plant)
      @files = T.let(files, T.untyped)
      @taken_at = T.let(taken_at, T.untyped)
    end

    sig { returns(Result) }
    def save
      files = Array(@files).reject(&:blank?)
      return missing_file_result if files.empty?

      create_images(files)
    end

    private

    sig { returns(Result) }
    def missing_file_result
      plant_image = @plant.plant_images.new(taken_at: @taken_at)
      plant_image.validate
      Result.new(saved: false, plant_image:)
    end

    sig { params(files: T::Array[T.untyped]).returns(Result) }
    def create_images(files)
      saved = T.let(true, T::Boolean)
      plant_image = T.let(nil, T.nilable(Plants::PlantImage))
      first_saved = T.let(nil, T.nilable(Plants::PlantImage))

      Plants::PlantImage.transaction do
        files.each do |file|
          current = @plant.plant_images.new(file:, taken_at: @taken_at)
          if current.save
            first_saved ||= current
            next
          end

          plant_image = current
          saved = false
          raise(ActiveRecord::Rollback)
        end

        if saved && first_saved && @plant.key_image_id.nil?
          @plant.update!(key_image: first_saved)
        end
      end

      return Result.new(saved: true) if saved

      Result.new(saved: false, plant_image:)
    end
  end
end
