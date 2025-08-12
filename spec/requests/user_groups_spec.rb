require "rails_helper"

RSpec.describe UserGroupsController do
  describe "index" do
    it "shows user groups for the current user" do
      me = create(:user)
      my_group = create(:user_group, owner: me)
      not_my_group = create(:user_group)
      login_as(me)

      get(user_groups_path)

      expect(page).to have_user_group(my_group)
      expect(page).not_to have_user_group(not_my_group)
    end

    it "requires authentication" do
      get(user_groups_path)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "create" do
    it "redirects" do
      user = create(:user)
      login_as(user)
      params = {user_group: {name: "Test Group"}}

      post(user_groups_path, params:)

      user_group = UserGroup.last
      expect(response).to redirect_to(user_group_path(user_group))
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {user_group: {name: ""}}

      post(user_groups_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end

    it "requires authentication" do
      params = {user_group: {name: "Test Group"}}

      post(user_groups_path, params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "show" do
    it "has crumbs" do
      user_group = create(:user_group)
      login_as(user_group.owner)

      get(user_group_path(user_group))

      expect(page).to have_link("User Groups", href: user_groups_path)
    end

    it "includes group details" do
      user = create(:user)
      user_group = create(:user_group, owner: user, name: "My Group")
      login_as(user)

      get(user_group_path(user_group))

      expect(page).to have_text("My Group")
      expect(page).to have_text(user.email)
      expect(page).to have_text("0 members")
    end

    it "returns 404 for groups not owned by current user" do
      user_group = create(:user_group)
      other_user = create(:user)
      login_as(other_user)

      get(user_group_path(user_group))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      user_group = create(:user_group)

      get(user_group_path(user_group))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "new" do
    it "has crumbs" do
      user = create(:user)
      login_as(user)

      get(new_user_group_path)

      expect(page).to have_link("User Groups", href: user_groups_path)
    end

    it "requires authentication" do
      get(new_user_group_path)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "edit" do
    it "has crumbs" do
      user_group = create(:user_group)
      login_as(user_group.owner)

      get(edit_user_group_path(user_group))

      expect(page).to have_link("User Groups", href: user_groups_path)
      expect(page).to have_link(user_group.name, href: user_group_path(user_group))
    end

    it "returns 404 when editing group not owned by current user" do
      user_group = create(:user_group)
      other_user = create(:user)
      login_as(other_user)

      get(edit_user_group_path(user_group))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication for edit" do
      user_group = create(:user_group)

      get(edit_user_group_path(user_group))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      user_group = create(:user_group, owner: user)
      login_as(user)
      params = {
        user_group: {
          name: "Updated Group"
        }
      }

      put(user_group_path(user_group), params:)

      expect(response).to redirect_to(user_group_path(user_group))
      expect(user_group.reload).to have_attributes({
        name: "Updated Group"
      })
    end

    it "shows error messages" do
      user = create(:user)
      user_group = create(:user_group, owner: user)
      login_as(user)
      params = {user_group: {name: ""}}

      put(user_group_path(user_group), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end

    it "returns 404 when updating group not owned by current user" do
      user_group = create(:user_group)
      other_user = create(:user)
      login_as(other_user)
      params = {user_group: {name: "updated"}}

      put(user_group_path(user_group), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication for update" do
      user_group = create(:user_group)
      params = {user_group: {name: "updated"}}

      put(user_group_path(user_group), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "destroy" do
    it "destroys the group and redirects" do
      user = create(:user)
      user_group = create(:user_group, owner: user)
      login_as(user)

      delete(user_group_path(user_group))

      expect(response).to redirect_to(user_groups_path)
      expect(UserGroup.exists?(user_group.id)).to eq(false)
    end

    it "returns 404 when destroying group not owned by current user" do
      user_group = create(:user_group)
      other_user = create(:user)
      login_as(other_user)

      delete(user_group_path(user_group))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication for destroy" do
      user_group = create(:user_group)

      delete(user_group_path(user_group))

      expect(response).to redirect_to(new_session_path)
    end
  end

  def have_user_group(user_group)
    have_css("[data-role=user_group]", text: user_group.name)
  end
end
