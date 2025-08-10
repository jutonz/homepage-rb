require "rails_helper"

RSpec.describe GalleriesController do
  describe "index" do
    it "shows galleries for the current user" do
      me = create(:user)
      my_gallery = create(:gallery, user: me)
      not_my_gallery = create(:gallery)
      login_as(me)

      get(galleries_path)

      expect(page).to have_gallery(my_gallery)
      expect(page).not_to have_gallery(not_my_gallery)
    end

    it "requires authentication" do
      get(galleries_path)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "create" do
    it "redirects" do
      user = create(:user)
      login_as(user)
      params = {gallery: {name: "hi"}}

      post(galleries_path, params:)

      gallery = Gallery.last
      expect(response).to redirect_to(gallery_path(gallery))
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {gallery: {name: ""}}

      post(galleries_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end
  end

  describe "show" do
    it "has crumbs" do
      gallery = create(:gallery)
      login_as(gallery.user)

      get(gallery_path(gallery))

      expect(page).to have_link("Galleries", href: galleries_path)
    end

    it "includes a count of the number of images" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create_pair(:galleries_image, gallery:)
      login_as(user)

      get(gallery_path(gallery))

      expect(page).to have_text("2 images")
    end

    it "doesn't raise an InvariantError if the image is not variable" do
      gallery = create(:gallery)
      create(
        :galleries_image,
        gallery:,
        file: Rack::Test::UploadedFile.new(
          fixture_file_upload("testing.pdf")
        )
      )
      login_as(gallery.user)

      expect {
        get(gallery_path(gallery))
      }.not_to raise_error
    end

    it "returns 404 for galleries not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      get(gallery_path(gallery))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      gallery = create(:gallery)

      get(gallery_path(gallery))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {
        gallery: {
          name: "after",
          hidden_at: "1"
        }
      }

      freeze_time do
        put(gallery_path(gallery), params:)

        expect(response).to redirect_to(gallery_path(gallery))
        expect(gallery.reload).to have_attributes({
          name: "after",
          hidden_at: Time.current
        })
      end
    end

    it "can unhide" do
      user = create(:user)
      gallery = create(:gallery, :hidden, user:)
      login_as(user)
      params = {
        gallery: {
          name: "after",
          hidden_at: nil
        }
      }

      put(gallery_path(gallery), params:)

      expect(response).to redirect_to(gallery_path(gallery))
      expect(gallery.reload).to have_attributes({
        hidden_at: nil
      })
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {gallery: {name: ""}}

      post(galleries_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end

    it "returns 404 when updating gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)
      params = {gallery: {name: "updated"}}

      put(gallery_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication for update" do
      gallery = create(:gallery)
      params = {gallery: {name: "updated"}}

      put(gallery_path(gallery), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "destroy" do
    it "returns 404 when destroying gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      delete(gallery_path(gallery))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication for destroy" do
      gallery = create(:gallery)

      delete(gallery_path(gallery))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "edit" do
    it "has crumbs" do
      gallery = create(:gallery)
      login_as(gallery.user)

      get(edit_gallery_path(gallery))

      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
    end

    it "returns 404 when editing gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      get(edit_gallery_path(gallery))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication for edit" do
      gallery = create(:gallery)

      get(edit_gallery_path(gallery))

      expect(response).to redirect_to(new_session_path)
    end
  end

  def have_gallery(gallery)
    have_css("[data-role=gallery]", text: gallery.name)
  end
end
