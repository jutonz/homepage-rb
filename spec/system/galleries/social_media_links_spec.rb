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

  it "can delete a social media link" do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:)
    create(:galleries_social_media_link,
      tag:,
      username: "deleteme")
    login_as(user)

    visit(gallery_tag_path(gallery, tag))

    expect(page).to have_css("[data-role=social-link]", text: "deleteme")

    within("[data-role=social-link]", text: "deleteme") do
      click_on("Delete")
    end

    expect(page).to have_text("Social media link was successfully deleted")
    expect(page).not_to have_css("[data-role=social-link]", text: "deleteme")
    expect(page).to have_text("No social media links added.")
  end
end
