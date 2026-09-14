# typed: strict

module Api
  module Plants
    class InboxImagesController < BaseController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      sig { void }
      def create
        inbox_image = T.let(
          current_user.plants_inbox_images.new(inbox_image_params),
          ::Plants::InboxImage
        )
        @inbox_image = T.let(
          authorize(inbox_image),
          T.nilable(::Plants::InboxImage)
        )

        if inbox_image.save
          render(json: inbox_image, status: :created)
        else
          render(
            json: {errors: inbox_image.errors.full_messages},
            status: :bad_request
          )
        end
      end

      private

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def inbox_image_params
        {
          file: params[:file],
          taken_at: params[:taken_at]
        }
      end
    end
  end
end
