# typed: strict

module Galleries
  class TagsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def index
      @gallery = T.let(find_gallery, T.nilable(Gallery))
      authorize Galleries::Tag
      @tags = T.let(
        Galleries::TagPolicy.scope_for(current_user)
          .where(gallery: @gallery)
          .includes(:gallery)
          .order(:name),
        T.nilable(T.all(ActiveRecord::Relation, T::Enumerable[Galleries::Tag]))
      )
    end

    sig { void }
    def new
      @gallery = find_gallery
      @tag = T.let(
        authorize(@gallery.tags.new(user: current_user)),
        T.nilable(Galleries::Tag)
      )
    end

    sig { void }
    def show
      @gallery = find_gallery
      @tag = authorize(find_tag(includes: {
        auto_add_tag_associations: :auto_add_tag
      }))
      @images = T.let(
        @tag
          .images
          .includes(file_attachment: :blob)
          .includes(:gallery)
          .order(created_at: :desc)
          .page(params[:page]),
        T.nilable(
          T.all(ActiveRecord::Relation, T::Enumerable[Galleries::Image])
        )
      )
      @related_tags = T.let(
        @tag.related_tags,
        T.nilable(T::Array[Galleries::RelatedTagsQuery::Result])
      )
    end

    sig { void }
    def create
      @gallery = find_gallery
      @tag = authorize(@gallery.tags.new(tag_params.merge(user: current_user)))

      if @tag.save
        Galleries::SocialLinksCreator.call(@tag)

        if params[:add_to_image_id]
          image = T.must(@gallery.images.find_by(id: params[:add_to_image_id]))
          image.add_tag(@tag)
          redirect_to([@gallery, image]) and return
        end

        redirect_to [@gallery, @tag], notice: "Tag was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    sig { void }
    def edit
      @gallery = find_gallery
      @tag = authorize(find_tag)
    end

    sig { void }
    def update
      @gallery = find_gallery
      @tag = authorize(find_tag)

      if @tag.update(tag_params)
        redirect_to [@gallery, @tag], notice: "Tag was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    sig { void }
    def destroy
      @gallery = find_gallery
      @tag = authorize(find_tag)
      @tag.destroy!

      redirect_to(
        gallery_tags_path(@gallery),
        status: :see_other,
        notice: "Tag was successfully destroyed."
      )
    end

    private

    sig { returns(Gallery) }
    def find_gallery
      GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
    end

    sig do
      params(includes: T.nilable(T::Hash[Symbol, Symbol]))
        .returns(Galleries::Tag)
    end
    def find_tag(includes: nil)
      query = Galleries::TagPolicy.scope_for(current_user)
        .where(gallery: @gallery)
      query = query.includes(includes) if includes.present?
      query.find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def tag_params
      params.require(:tag).permit(:name, :classification)
    end
  end
end
