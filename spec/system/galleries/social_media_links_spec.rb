require "rails_helper"

RSpec.describe "Gallery social media links" do
  it "can add and edit a social link on a tag" do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:)
    login_as(user)

    visit(gallery_tag_path(gallery, tag))
    click_on("Add social media link")

    fill_in("Username", with: "testuser")
    click_on("Create Social media link")

    within("[data-role=social-link]", text: "testuser") do
      click_on("Edit")
    end

    select("tiktok", from: "Platform")
    fill_in("Username", with: "testuser2")
    click_on("Update Social media link")

    expect(page).to have_css(
      "[data-role=social-link]",
      text: "testuser2"
    )
  end
end
