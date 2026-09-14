# typed: strict

module Plants
  module InboxImages
    class AssignmentsController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      sig { void }
      def create
        inbox_image = find_inbox_image
        @inbox_image = T.let(
          authorize(inbox_image, :assign?),
          T.nilable(Plants::InboxImage)
        )
        plant =
          Plants::PlantPolicy.scope_for(current_user).find(params[:plant_id])
        plant_image = plant.plant_images.new(taken_at: inbox_image.taken_at)
        plant_image.file.attach(inbox_image.file.blob)

        if plant_image.save
          inbox_image.destroy!
          redirect_to(plant_path(plant), notice: "Image was assigned.")
          return
        end

        flash.now[:alert] =
          plant_image.errors.full_messages.to_sentence
        @plants = T.let(
          Plants::PlantPolicy.scope_for(current_user)
            .includes(key_image: :file_attachment)
            .order(:name),
          T.nilable(
            T.all(ActiveRecord::Relation, T::Enumerable[Plants::Plant])
          )
        )
        render("plants/inbox_images/show", status: :unprocessable_content)
      end

      private

      sig { returns(Plants::InboxImage) }
      def find_inbox_image
        Plants::InboxImagePolicy.scope_for(current_user)
          .find(params[:inbox_image_id])
      end
    end
  end
end
