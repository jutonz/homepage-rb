module Galleries
  class TagsController < ApplicationController
    before_action :ensure_authenticated!

    def index
      @gallery = find_gallery
      @tags = @gallery.tags.order(:name)
    end

    def new
      @gallery = find_gallery
      @tag = @gallery.tags.new
    end

    def show
      @gallery = find_gallery
      @tag = find_tag
      @images =
        @tag
          .images
          .includes(:file_attachment)
          .order(created_at: :desc)
          .page(params[:page])
    end

    def create
      @gallery = find_gallery
      @tag = @gallery.tags.new(tag_params)
      @tag.user = current_user

      if @tag.save
        if params[:add_to_image_id]
          image = @gallery.images.find_by(id: params[:add_to_image_id])
          image.add_tag(@tag)
          redirect_to([@gallery, image]) and return
        end

        redirect_to [@gallery, @tag], notice: "Tag was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @gallery = find_gallery
      @tag = find_tag
    end

    def update
      @gallery = find_gallery
      @tag = find_tag

      if @tag.update(tag_params)
        redirect_to [@gallery, @tag], notice: "Tag was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @gallery = find_gallery
      @tag = find_tag
      @tag.destroy!

      redirect_to(
        gallery_tags_path(@gallery),
        status: :see_other,
        notice: "Tag was successfully destroyed."
      )
    end

    private

    def find_gallery
      current_user
        .galleries
        .find(params[:gallery_id])
    end

    def find_tag
      @gallery.tags.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
  end
end
