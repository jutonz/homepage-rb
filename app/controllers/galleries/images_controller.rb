module Galleries
  class ImagesController < ApplicationController
    before_action :ensure_authenticated!

    def index
      @gallery = find_gallery.includes(:images)
    end

    def show
      @gallery = find_gallery
      @image = find_image
    end

    def new
      @gallery = find_gallery
      @image = @gallery.images.new
    end

    def edit
      @gallery = find_gallery
      @image = find_image
    end

    def create
      @gallery = find_gallery
      @image = @gallery.images.new(image_params)

      if @image.save
        redirect_to [@gallery, @image], notice: "Image was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
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
