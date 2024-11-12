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

      expect(response).to have_http_status(:unprocessable_entity)
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
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {gallery: {name: "after"}}

      put(gallery_path(gallery), params:)

      expect(response).to redirect_to(gallery_path(gallery))
      expect(gallery.reload).to have_attributes(params[:gallery])
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {gallery: {name: ""}}

      post(galleries_path, params:)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(page).to have_text("can't be blank")
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
  end

  def have_gallery(gallery)
    have_css("[data-role=gallery]", text: gallery.name)
  end
end
