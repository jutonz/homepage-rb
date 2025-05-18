require "rails_helper"

RSpec.describe Galleries::ImagesController do
  describe "index" do
    it "shows images for the gallery" do
      user = create(:user)
      gallery, other_gallery = create_pair(:gallery, user:)
      image = create(:galleries_image, gallery:)
      other_image = create(:galleries_image, gallery: other_gallery)
      login_as(user)

      get(gallery_path(gallery))

      expect(page).to have_image_thumbnail(image)
      expect(page).not_to have_image_thumbnail(other_image)
    end
  end

  describe "show" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)

      get(gallery_image_path(gallery, image))

      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
    end

    it "shows tags sorted by name" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      tag2 = create(:galleries_tag, gallery:, name: "tag 2")
      tag1 = create(:galleries_tag, gallery:, name: "tag 1")
      image.add_tag(tag2)
      image.add_tag(tag1)
      login_as(user)

      get(gallery_image_path(gallery, image))

      tags = page.all("[data-role=tag-link]").map { it.text.strip }
      expect(tags).to eql(["tag 1 (1)", "tag 2 (1)"])
    end

    it "shows similar images" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image1, image2 = create_pair(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:)
      image1.add_tag(tag)
      image1.add_tag(tag)
      login_as(user)

      get(gallery_image_path(gallery, image1))

      within("[data-role=similar-images]") do
        expect(page).to have_css(
          "[data-image-id='#{image2.id}']"
        )
      end
    end

    it "has an empty state for images similar by phash" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      login_as(gallery.user)

      get(gallery_image_path(gallery, image))

      expect(response).to have_http_status(:ok)
      expect(page).to have_text("This image doesn't have a perceptual_hash")
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)
      params = {image: {file: fixture_file_upload("audiosurf.jpg", "image/jpeg")}}

      put(gallery_image_path(gallery, image), params:)

      expect(response).to redirect_to(gallery_image_path(gallery, image))
    end
  end

  describe "edit" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)

      get(edit_gallery_image_path(gallery, image))

      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
    end
  end

  describe "destroy" do
    it "deletes the image" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image1 = create(:galleries_image, gallery:)
      login_as(user)

      delete(gallery_image_path(gallery, image1))

      expect(response).to redirect_to(gallery_path(gallery))
    end
  end

  def have_image_thumbnail(image)
    have_css("[data-role=image-thumbnail][data-image-id='#{image.id}']")
  end
end
