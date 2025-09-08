module Galleries
  class TagsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      @gallery = find_gallery
      authorize Galleries::Tag
      @tags = policy_scope(Galleries::Tag).where(gallery: @gallery).order(:name)
    end

    def new
      @gallery = find_gallery
      @tag = authorize(@gallery.tags.new(user: current_user))
    end

    def show
      @gallery = find_gallery
      @tag = authorize(find_tag(includes: [
        auto_add_tag_associations: :auto_add_tag
      ]))
      @images =
        @tag
          .images
          .includes(:file_attachment)
          .includes(:gallery)
          .order(created_at: :desc)
          .page(params[:page])
    end

    def create
      @gallery = find_gallery
      @tag = authorize(@gallery.tags.new(tag_params.merge(user: current_user)))

      if @tag.save
        # Check if this is a social tag that resolves to an existing tag
        resolved_tag = SocialLinksCreator.call(@tag)

        if resolved_tag != @tag
          # This was a duplicate social tag, redirect to existing tag
          # and clean up the tag we just created since it's not needed
          @tag.destroy!
          @tag = resolved_tag
          notice_message = "Tag already exists with that social media link."
        else
          notice_message = "Tag was successfully created."
        end

        if params[:add_to_image_id]
          image = @gallery.images.find_by(id: params[:add_to_image_id])
          image.add_tag(@tag)
          redirect_to([@gallery, image], notice: notice_message) and return
        end

        redirect_to [@gallery, @tag], notice: notice_message
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @gallery = find_gallery
      @tag = authorize(find_tag)
    end

    def update
      @gallery = find_gallery
      @tag = authorize(find_tag)

      if @tag.update(tag_params)
        redirect_to [@gallery, @tag], notice: "Tag was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

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

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def find_tag(includes: nil)
      query = policy_scope(Galleries::Tag).where(gallery: @gallery)
      query = query.includes(includes) if includes.present?
      query.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
  end
end
