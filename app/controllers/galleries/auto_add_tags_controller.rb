# typed: strict

module Galleries
  class AutoAddTagsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def new
      gallery = find_gallery
      @gallery = T.let(gallery, T.nilable(Gallery))
      tag = find_tag(gallery)
      @tag = T.let(tag, T.nilable(Galleries::Tag))
      @auto_add_tag = T.let(
        authorize(tag.auto_add_tag_associations.build),
        T.nilable(Galleries::AutoAddTag)
      )
      @tag_search = T.let(
        Galleries::TagSearch.new(gallery:, auto_add_source: tag),
        T.nilable(Galleries::TagSearch)
      )
    end

    sig { void }
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

    sig { void }
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

    sig { returns(Gallery) }
    def find_gallery
      GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
    end

    sig { params(gallery: Gallery).returns(Galleries::Tag) }
    def find_tag(gallery)
      Galleries::TagPolicy.scope_for(current_user)
        .where(gallery:)
        .find(params[:tag_id])
    end

    sig { params(tag: Galleries::Tag).returns(Galleries::AutoAddTag) }
    def find_auto_add_tag(tag)
      Galleries::AutoAddTagPolicy.scope_for(current_user)
        .where(tag:)
        .find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def auto_add_tag_params
      params.expect(auto_add_tag: %i[auto_add_tag_id])
    end
  end
end
