module Galleries
  class ImagesController < ApplicationController
    before_action :ensure_authenticated!

    def index
      @gallery = find_gallery.includes(:images)
    end

    def show
      @gallery = find_gallery
      @image = find_image
      @tag_search = Galleries::TagSearch.new(
        gallery: @gallery,
        image: @image,
        query: params[:tag_query]
      )
    end

    def edit
      @gallery = find_gallery
      @image = find_image
    end

    def update
      @gallery = find_gallery
      @image = find_image

      if @image.update(image_params)
        redirect_to [@gallery, @image], notice: "Image was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @gallery = find_gallery
      @image = find_image
      @image.destroy!

      redirect_to(
        gallery_path(@gallery),
        status: :see_other,
        notice: "Image was successfully destroyed."
      )
    end

    private

    def find_gallery
      current_user.galleries.find(params[:gallery_id])
    end

    def find_image
      @gallery.images.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:file)
    end
  end
end
