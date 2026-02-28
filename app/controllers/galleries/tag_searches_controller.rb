module Galleries
  class TagSearchesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def show
      @gallery = find_gallery
      authorize(@gallery, :show?)
      @tag_search = Galleries::TagSearch.new(
        gallery: @gallery,
        query: params.dig(:tag_search, :query)
      )

      respond_to do |format|
        format.html
      end
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end
  end
end
