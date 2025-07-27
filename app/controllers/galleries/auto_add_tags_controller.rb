module Galleries
  class AutoAddTagsController < ApplicationController
    before_action :ensure_authenticated!

    def new
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @auto_add_tag = @tag.auto_add_tag_associations.build
    end

    def create
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @auto_add_tag = @tag.auto_add_tag_associations.build(auto_add_tag_params)

      if @auto_add_tag.save
        redirect_to(
          gallery_tag_path(@gallery, @tag),
          notice: "Auto add tag was successfully created"
        )
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      auto_add_tag = find_auto_add_tag(@tag)
      auto_add_tag.destroy!

      redirect_to(
        gallery_tag_path(@gallery, @tag),
        notice: "Auto add tag was successfully removed"
      )
    end

    private

    def find_gallery
      current_user.galleries.find(params[:gallery_id])
    end

    def find_tag(gallery)
      gallery.tags.find(params[:tag_id])
    end

    def find_auto_add_tag(tag)
      tag.auto_add_tag_associations.find(params[:id])
    end

    def auto_add_tag_params
      params.expect(auto_add_tag: %i[auto_add_tag_id])
    end
  end
end
