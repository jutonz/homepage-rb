require "rails_helper"

RSpec.describe Galleries::ImagesController do
  describe "index" do
    it "shows images for the gallery" do
      user = create(:user)
      gallery, other_gallery = create_pair(:gallery, user:)
      image = create(:image, gallery:)
      other_image = create(:image, gallery: other_gallery)
      login_as(user)

      get(gallery_path(gallery))

      expect(page).to have_image(image)
      expect(page).not_to have_image(other_image)
    end
  end

  describe "show" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:image, gallery:)
      login_as(user)

      get(gallery_image_path(gallery, image))

      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:image, gallery:)
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
      image = create(:image, gallery:)
      login_as(user)

      get(edit_gallery_image_path(gallery, image))

      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
    end
  end

  def have_image(image)
    have_css("[data-role=image][data-image-id='#{image.id}']")
  end
end
