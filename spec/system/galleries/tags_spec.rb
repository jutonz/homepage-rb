require "rails_helper"

RSpec.describe "Gallery tags page" do
  it "displays tags with counts" do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag1 = create(:galleries_tag, gallery:, name: "Nature")
    _tag2 = create(:galleries_tag, gallery:, name: "Portrait")
    image = create(:galleries_image, gallery:)
    create(:galleries_image_tag, image:, tag: tag1)
    login_as(user)

    visit(gallery_tags_path(gallery))

    expect(page).to have_content("Tags")
    expect(page).to have_css("[data-role='tag']", count: 2)

    within("[data-role='tag']", text: "Nature") do
      expect(page).to have_content("Nature")
      expect(page).to have_content("1")
    end

    within("[data-role='tag']", text: "Portrait") do
      expect(page).to have_content("Portrait")
      expect(page).to have_content("0")
    end
  end

  it "shows empty state when no tags exist" do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)

    visit(gallery_tags_path(gallery))

    expect(page).to have_content("No tags yet")
    expect(page).to have_content("Create your first tag to get started")
    expect(page).not_to have_css("[data-role='tag']")
  end

  it "links to individual tag pages" do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:, name: "Landscape")
    login_as(user)

    visit(gallery_tags_path(gallery))

    click_on("Landscape")

    expect(current_path).to eq(gallery_tag_path(gallery, tag))
    expect(page).to have_content("Landscape")
  end

  it "displays gallery stats" do
    user = create(:user)
    gallery = create(:gallery, user:)
    create_list(:galleries_image, 3, gallery:)
    create_list(:galleries_tag, 2, gallery:)
    login_as(user)

    visit(gallery_tags_path(gallery))

    expect(page).to have_content("3 images")
    expect(page).to have_content("2 tags")
  end

  it "manages a tag" do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)

    visit(gallery_tags_path(gallery))
    click_on("New Tag")

    fill_in("Name", with: "Sunset")
    click_on("Create Tag")

    expect(page).to have_content("Tag was successfully created")
    expect(page).to have_content("Sunset")

    click_on("Edit")
    fill_in("Name", with: "Beautiful Sunset")
    click_on("Update Tag")

    expect(page).to have_content("Tag was successfully updated")
    expect(page).to have_content("Beautiful Sunset")

    click_on("Delete")

    expect(page).to have_content("Tag was successfully destroyed")
    expect(current_path).to eq(gallery_tags_path(gallery))
    expect(page).not_to have_content("Beautiful Sunset")
  end

  it "orders tags alphabetically" do
    user = create(:user)
    gallery = create(:gallery, user:)
    create(:galleries_tag, gallery:, name: "Zebra")
    create(:galleries_tag, gallery:, name: "Apple")
    create(:galleries_tag, gallery:, name: "Mountain")
    login_as(user)

    visit(gallery_tags_path(gallery))

    tag_names = page.all("[data-role='tag']").map(&:text)
    expect(tag_names.first).to include("Apple")
    expect(tag_names.last).to include("Zebra")
  end
end
