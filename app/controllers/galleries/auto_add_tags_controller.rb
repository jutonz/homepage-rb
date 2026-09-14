# typed: true

module Galleries
  class AutoAddTagsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def new
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @auto_add_tag = authorize(@tag.auto_add_tag_associations.build)
      @tag_search = Galleries::TagSearch.new(
        gallery: @gallery,
        auto_add_source: @tag
      )
    end

    def create
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @auto_add_tag = authorize(@tag.auto_add_tag_associations.build(auto_add_tag_params))

      if @auto_add_tag.save
        BackfillAutoTagsJob.perform_later(@auto_add_tag)
        redirect_to(
          gallery_tag_path(@gallery, @tag),
          notice: "Auto add tag was successfully created"
        )
      else
        @tag_search = Galleries::TagSearch.new(
          gallery: @gallery,
          auto_add_source: @tag
        )
        flash.now[:alert] = @auto_add_tag.errors.full_messages.to_sentence
        render(:new, status: :unprocessable_content)
      end
    end

    def destroy
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      auto_add_tag = authorize(find_auto_add_tag(@tag))
      auto_add_tag.destroy!

      redirect_to(
        gallery_tag_path(@gallery, @tag),
        notice: "Auto add tag was successfully removed"
      )
    end

    private

    def find_gallery
      GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
    end

    def find_tag(gallery)
      Galleries::TagPolicy.scope_for(current_user)
        .where(gallery:)
        .find(params[:tag_id])
    end

    def find_auto_add_tag(tag)
      Galleries::AutoAddTagPolicy.scope_for(current_user)
        .where(tag:)
        .find(params[:id])
    end

    def auto_add_tag_params
      params.expect(auto_add_tag: %i[auto_add_tag_id])
    end
  end
end
