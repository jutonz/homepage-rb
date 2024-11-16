module Galleries
  class TagsController < ApplicationController
    before_action :ensure_authenticated!

    def index
      @gallery = find_gallery(includes: :tags)
    end

    def new
      @gallery = find_gallery
      @tag = @gallery.tags.new
    end

    def show
      @gallery = find_gallery
      @tag = find_tag
    end

    def create
      @gallery = find_gallery
      @tag = @gallery.tags.new(tag_params)
      @tag.user = current_user

      if @tag.save
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

    def find_gallery(includes: nil)
      current_user
        .galleries
        .tap { _1.includes(includes) if includes.present? }
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
