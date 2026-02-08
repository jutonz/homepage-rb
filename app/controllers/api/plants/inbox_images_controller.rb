module Api
  module Plants
    class InboxImagesController < BaseController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @inbox_image = authorize(
          current_user.plants_inbox_images.new(inbox_image_params)
        )

        if @inbox_image.save
          render json: @inbox_image, status: :created
        else
          render json: {
            errors: @inbox_image.errors.full_messages
          }, status: :bad_request
        end
      end

      private

      def inbox_image_params
        {
          file: params[:file],
          taken_at: params[:taken_at]
        }
      end
    end
  end
end
