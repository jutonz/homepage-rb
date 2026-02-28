require "rails_helper"

RSpec.describe "Gallery show page" do
  it "paginates" do
    stub_const("GalleriesController::PER_PAGE", 1)
    user = create(:user)
    gallery = create(:gallery, user:)
    image1, image2 = create_pair(:galleries_image, gallery:)
    login_as(user)

    visit(gallery_path(gallery))

    expect(page).not_to have_css("[data-image-id='#{image1.id}']")
    expect(page).to have_css("[data-image-id='#{image2.id}']")

    click_on("Next ›")

    expect(page).to have_css("[data-image-id='#{image1.id}']")
    expect(page).not_to have_css("[data-image-id='#{image2.id}']")
    expect(URI.parse(current_url).query).to eql("page=2")
  end

  it "enters select mode when clicking Select" do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)

    visit(gallery_path(gallery))

    expect(page).to have_link("Select")
    expect(page).to have_link("Edit")

    click_on("Select")

    expect(page).to have_link("Cancel")
    expect(page).not_to have_link("Edit")
    expect(page).not_to have_link("Select")
    expect(URI.parse(current_url).query).to include("select=true")
  end

  it "selects and deselects an image in select mode", js: true do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery, select: true))

    thumbnail = find("[data-image-id='#{image.id}']")
    expect(thumbnail).not_to match_css(".ring-4")

    thumbnail.click

    thumbnail = find("[data-image-id='#{image.id}']")
    expect(thumbnail).to match_css(".ring-4")
    expect(URI.parse(current_url).query).to include(
      "selected_ids%5B%5D=#{image.id}"
    )

    thumbnail.click

    thumbnail = find("[data-image-id='#{image.id}']")
    expect(thumbnail).not_to match_css(".ring-4")
    expect(URI.parse(current_url).query.to_s).not_to include(
      "selected_ids%5B%5D=#{image.id}"
    )
  end

  it "preserves tag filter and selection after page refresh", js: true do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:)
    tagged_image = create(:galleries_image, :with_real_file, gallery:)
    untagged_image = create(:galleries_image, :with_real_file, gallery:)
    tagged_image.add_tag(tag)
    login_as(user)

    visit(
      gallery_path(gallery, tag_ids: [tag.id], select: true)
    )

    expect(page).to have_css("[data-image-id='#{tagged_image.id}']")
    expect(page).not_to have_css(
      "[data-image-id='#{untagged_image.id}']"
    )

    find("[data-image-id='#{tagged_image.id}']").click

    expect(find("[data-image-id='#{tagged_image.id}']")).to(
      match_css(".ring-4")
    )

    page.refresh

    expect(page).to have_css("[data-image-id='#{tagged_image.id}']")
    expect(page).not_to have_css(
      "[data-image-id='#{untagged_image.id}']"
    )
    expect(find("[data-image-id='#{tagged_image.id}']")).to(
      match_css(".ring-4")
    )
  end

  it "preserves selection when navigating between pages", js: true do
    stub_const("GalleriesController::PER_PAGE", 1)
    user = create(:user)
    gallery = create(:gallery, user:)
    image1, image2 = create_pair(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    # images are ordered created_at desc, so image2 is on page 1
    visit(gallery_path(gallery, select: true))

    expect(page).to have_css("[data-image-id='#{image2.id}']")
    find("[data-image-id='#{image2.id}']").click
    expect(find("[data-image-id='#{image2.id}']")).to match_css(".ring-4")

    click_on("Next ›")

    expect(page).to have_css("[data-image-id='#{image1.id}']")
    expect(URI.parse(current_url).query).to include(
      "selected_ids%5B%5D=#{image2.id}"
    )

    click_on("‹ Prev")

    expect(find("[data-image-id='#{image2.id}']")).to match_css(".ring-4")
  end

  it "cancels select mode and clears selection" do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    login_as(user)

    visit(
      gallery_path(gallery, select: true, selected_ids: [image.id])
    )

    expect(page).to have_link("Cancel")

    click_on("Cancel")

    expect(page).to have_link("Edit")
    expect(page).not_to have_link("Cancel")
    query = URI.parse(current_url).query.to_s
    expect(query).not_to include("select")
    expect(query).not_to include("selected_ids")
  end
end
