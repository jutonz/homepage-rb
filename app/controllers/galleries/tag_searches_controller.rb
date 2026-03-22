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

      html = TagSearches::ResultsComponent.new(
        tag_search: @tag_search,
        mode: search_params["mode"]&.to_sym,
        turbo_frame_tag: search_params["turbo_frame_tag"]
      ).render_in(view_context)

      render(html:)
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def search_params
      params.fetch(:tag_search, {}).permit(:mode, :turbo_frame_tag)
    end
  end
end
