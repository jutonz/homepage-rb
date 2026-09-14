# typed: true

module Galleries
  class TagSearchesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def show
      @gallery = find_gallery
      authorize(@gallery, :show?)
      @tag_search = Galleries::TagSearch.new(
        gallery: @gallery,
        query: params.dig(:tag_search, :query),
        auto_add_source: find_auto_add_source
      )

      html = TagSearches::ResultsComponent.new(
        **T.unsafe({tag_search: @tag_search, **results_options})
      ).render_in(view_context)

      render(html:)
    end

    private

    def find_gallery
      GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
    end

    def search_params
      params
        .fetch(:tag_search, {})
        .permit(:mode, :turbo_frame_tag, :auto_add_source_id)
    end

    def find_auto_add_source
      return unless search_params[:mode] == "auto_add"

      Galleries::TagPolicy.scope_for(current_user)
        .where(gallery: @gallery)
        .find(search_params[:auto_add_source_id])
    end

    def results_options
      {
        mode: search_params[:mode].presence&.to_sym,
        turbo_frame_tag: search_params[:turbo_frame_tag].presence
      }.compact
    end
  end
end
