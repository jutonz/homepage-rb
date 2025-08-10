module Galleries
  class ImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      @gallery = find_gallery
      authorize(Galleries::Image)
      @images =
        policy_scope(Galleries::Image)
          .where(gallery: @gallery)
          .includes(:file_attachment)
    end

    def show
      @gallery = find_gallery
      @image = authorize(find_image)
      @tag_search = Galleries::TagSearch.new(
        gallery: @gallery,
        image: @image,
        query: params[:tag_query]
      )
    end

    def edit
      @gallery = find_gallery
      @image = authorize(find_image)
    end

    def update
      @gallery = find_gallery
      @image = authorize(find_image)

      if @image.update(image_params)
        redirect_to [@gallery, @image], notice: "Image was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @gallery = find_gallery
      @image = authorize(find_image)
      @image.destroy!

      redirect_to(
        gallery_path(@gallery),
        status: :see_other,
        notice: "Image was successfully destroyed."
      )
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def find_image
      policy_scope(Galleries::Image).where(gallery: @gallery).find(params[:id])
    end

    def image_params
      params.require(:image).permit(:file)
    end
  end
end
