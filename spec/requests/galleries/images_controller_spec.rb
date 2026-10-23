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

    it "loads books for the image" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      book1 = create(:galleries_book, gallery:, name: "Book A")
      book2 = create(:galleries_book, gallery:, name: "Book B")
      create(:galleries_book_image, book: book1, image:)
      create(:galleries_book_image, book: book2, image:)
      login_as(user)

      get(gallery_image_path(gallery, image))

      expect(page).to have_css('[data-role="book"]', count: 2)
      expect(page).to have_link("Book A")
      expect(page).to have_link("Book B")
    end

    it "links to the source url in a new tab" do
      gallery = create(:gallery)
      image = create(
        :galleries_image,
        gallery:,
        source_url: "https://example.com/post"
      )
      login_as(gallery.user)

      get(gallery_image_path(gallery, image))

      source = page.find("[data-role=source-url]")
      expect(source).to have_text("Source")
      link = source.find_link(
        "https://example.com/post",
        href: "https://example.com/post"
      )
      expect(link[:target]).to eq("_blank")
      expect(link[:rel]).to eq("noopener noreferrer")
    end

    it "shows no source when the image has no source url" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:, source_url: nil)
      login_as(gallery.user)

      get(gallery_image_path(gallery, image))

      expect(page).not_to have_css("[data-role=source-url]")
    end

    it "does not show book section when image has no books" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)

      get(gallery_image_path(gallery, image))

      expect(page).not_to have_text("In Books")
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

  describe "update source_url" do
    it "sets the source url and keeps the file" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      blob_id = image.file.blob.id
      login_as(gallery.user)
      params = {image: {source_url: "https://example.com/post"}}

      put(gallery_image_path(gallery, image), params:)

      expect(response).to redirect_to(gallery_image_path(gallery, image))
      image.reload
      expect(image.source_url).to eq("https://example.com/post")
      expect(image.file.blob.id).to eq(blob_id)
    end

    it "clears the source url" do
      gallery = create(:gallery)
      image = create(
        :galleries_image,
        gallery:,
        source_url: "https://example.com/post"
      )
      login_as(gallery.user)
      params = {image: {source_url: ""}}

      put(gallery_image_path(gallery, image), params:)

      expect(response).to redirect_to(gallery_image_path(gallery, image))
      expect(image.reload.source_url).to be_nil
    end

    it "rejects an invalid source url" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      login_as(gallery.user)
      params = {image: {source_url: "javascript:alert(1)"}}

      put(gallery_image_path(gallery, image), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("is not a valid http(s) URL")
      expect(image.reload.source_url).to be_nil
    end
  end

  describe "edit" do
    it "has a source url field" do
      gallery = create(:gallery)
      image = create(
        :galleries_image,
        gallery:,
        source_url: "https://example.com/post"
      )
      login_as(gallery.user)

      get(edit_gallery_image_path(gallery, image))

      expect(page).to have_field(
        "Source URL",
        type: "url",
        with: "https://example.com/post"
      )
    end

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

    it "returns 404 when destroying image from gallery not owned by current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_user = create(:user)
      login_as(other_user)

      delete(gallery_image_path(gallery, image))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)

      delete(gallery_image_path(gallery, image))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "show authorization" do
    it "returns 404 when viewing image from gallery not owned by current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(gallery_image_path(gallery, image))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)

      get(gallery_image_path(gallery, image))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "edit authorization" do
    it "returns 404 when editing image from gallery not owned by current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(edit_gallery_image_path(gallery, image))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)

      get(edit_gallery_image_path(gallery, image))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "update authorization" do
    it "returns 404 when updating image from gallery not owned by current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_user = create(:user)
      login_as(other_user)
      params = {image: {file: fixture_file_upload("audiosurf.jpg", "image/jpeg")}}

      put(gallery_image_path(gallery, image), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication for update" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      params = {image: {file: fixture_file_upload("audiosurf.jpg", "image/jpeg")}}

      put(gallery_image_path(gallery, image), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  def have_image_thumbnail(image)
    have_css("[data-role=image-thumbnail][data-image-id='#{image.id}']")
  end
end
