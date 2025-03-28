module Galleries
  class TagSearchesController < ApplicationController
    before_action :ensure_authenticated!

    def show
      @gallery = find_gallery
      @image = find_image
      @tag_search = TagSearch.new(
        gallery: @gallery,
        image: @image,
        query: tag_search_params[:query]
      )

      respond_to do |format|
        format.turbo_stream
        format.html { render "galleries/images/show" }
      end
    end

    private

    def find_gallery
      current_user.galleries.find(params[:gallery_id])
    end

    def find_image
      @gallery.images.find(tag_search_params[:image_id])
    end

    def tag_search_params
      params.require(:tag_search).permit(:query, :image_id)
    end
  end
end
