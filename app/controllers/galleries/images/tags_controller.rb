# typed: strict

module Galleries
  module Images
    class TagsController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      sig { void }
      def create
        @gallery = T.let(find_gallery, T.nilable(Gallery))
        image = find_image
        @image = T.let(image, T.nilable(Galleries::Image))
        tag = authorize(find_tag)
        @tag = T.let(tag, T.nilable(Galleries::Tag))

        image.add_tag(tag)
        @from_related = T.let(
          params[:from_related].present?,
          T.nilable(T::Boolean)
        )

        unless @from_related
          @related_tags = T.let(
            Galleries::RelatedTagsQuery.call(
              tag:,
              exclude_tag_ids: image.tag_ids,
              limit: 5
            ),
            T.nilable(T::Array[Galleries::RelatedTagsQuery::Result])
          )
        end

        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to(
              gallery_image_path(@gallery, image),
              notice: "Added tag"
            )
          end
        end
      end

      sig { void }
      def destroy
        @gallery = find_gallery
        @image = find_image
        @tag = authorize(find_tag)

        @image.remove_tag(@tag)

        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to(
              gallery_image_path(@gallery, @image),
              notice: "Removed tag"
            )
          end
        end
      end

      private

      sig { returns(Gallery) }
      def find_gallery
        GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
      end

      sig { returns(Galleries::Image) }
      def find_image
        Galleries::ImagePolicy.scope_for(current_user)
          .where(gallery: @gallery)
          .find(params[:image_id])
      end

      sig { returns(Galleries::Tag) }
      def find_tag
        Galleries::TagPolicy.scope_for(current_user)
          .where(gallery: @gallery)
          .find(params[:tag_id] || params[:id])
      end
    end
  end
end
