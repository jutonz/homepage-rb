module Galleries
  class SocialMediaLinksController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def new
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @social_media_link = authorize(@tag.social_media_links.build)
      render :new
    end

    def create
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @social_media_link = authorize(@tag.social_media_links.build(link_params))

      if @social_media_link.save
        redirect_to(
          gallery_tag_path(@gallery, @tag),
          notice: "Created social media link!"
        )
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @social_media_link = authorize(find_link(@tag))
      render :edit
    end

    def update
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @social_media_link = authorize(find_link(@tag))

      if @social_media_link.update(link_params)
        redirect_to(
          gallery_tag_path(@gallery, @tag),
          notice: "Updated social media link!"
        )
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @gallery = find_gallery
      @tag = find_tag(@gallery)
      @social_media_link = authorize(find_link(@tag))

      @social_media_link.destroy!
      redirect_to(
        gallery_tag_path(@gallery, @tag),
        notice: "Social media link was successfully deleted."
      )
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def find_tag(gallery)
      policy_scope(Galleries::Tag).where(gallery:).find(params[:tag_id])
    end

    def find_link(tag)
      policy_scope(Galleries::SocialMediaLink).where(tag:).find(params[:id])
    end

    def link_params
      params.expect(social_media_link: %i[platform username])
    end
  end
end
