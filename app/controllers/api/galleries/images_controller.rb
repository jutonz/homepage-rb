module Api
  module Galleries
    class ImagesController < BaseController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @gallery = find_gallery
        @image = authorize(@gallery.images.build(image_params))

        if @image.save
          @image.add_tag(tagging_needed)
          ::Galleries::ImageVariantJob.perform_later(@image)
          ::Galleries::ImagePerceptualHashJob.perform_later(@image)
          render json: @image, status: :created
        else
          render json: {
            errors: @image.errors.full_messages
          }, status: :bad_request
        end
      end

      private

      def find_gallery
        policy_scope(Gallery).find(params[:gallery_id])
      end

      def image_params
        {file: params[:file]}
      end

      def tagging_needed
        ::Galleries::Tag.tagging_needed(@gallery)
      end
    end
  end
end
