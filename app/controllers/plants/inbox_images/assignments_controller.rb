module Plants
  module InboxImages
    class AssignmentsController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @inbox_image = authorize(find_inbox_image, :assign?)
        plant = policy_scope(Plants::Plant).find(params[:plant_id])
        plant_image = plant.plant_images.new(taken_at: @inbox_image.taken_at)
        plant_image.file.attach(@inbox_image.file.blob)

        if plant_image.save
          @inbox_image.destroy!
          redirect_to(plant_path(plant), notice: "Image was assigned.")
          return
        end

        flash.now[:alert] =
          plant_image.errors.full_messages.to_sentence
        @plants =
          policy_scope(Plants::Plant)
            .includes(key_image: :file_attachment)
            .order(:name)
        render("plants/inbox_images/show", status: :unprocessable_content)
      end

      private

      def find_inbox_image
        policy_scope(Plants::InboxImage).find(params[:inbox_image_id])
      end
    end
  end
end
