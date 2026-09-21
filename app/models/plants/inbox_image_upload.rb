# typed: strict

module Plants
  class InboxImageUpload
    Result = Struct.new(:saved, :inbox_image) do
      sig { returns(T::Boolean) }
      def saved?
        saved
      end
    end

    sig do
      params(
        user: User,
        files: T.untyped,
        taken_at: T.untyped
      ).void
    end
    def initialize(user:, files:, taken_at:)
      @user = T.let(user, User)
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
      inbox_image = @user.plants_inbox_images.new(taken_at: @taken_at)
      inbox_image.validate
      Result.new(saved: false, inbox_image:)
    end

    sig { params(files: T::Array[T.untyped]).returns(Result) }
    def create_images(files)
      saved = T.let(true, T::Boolean)
      inbox_image = T.let(nil, T.nilable(Plants::InboxImage))

      Plants::InboxImage.transaction do
        files.each do |file|
          current = @user.plants_inbox_images.new(file:, taken_at: @taken_at)
          next if current.save

          inbox_image = current
          saved = false
          raise ActiveRecord::Rollback
        end
      end

      return Result.new(saved: true) if saved

      Result.new(saved: false, inbox_image:)
    end
  end
end
