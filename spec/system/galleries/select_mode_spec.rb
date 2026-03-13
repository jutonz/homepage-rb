require "rails_helper"

RSpec.describe "Gallery select mode" do
  it "enters select mode when clicking Select", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)

    visit(gallery_path(gallery))

    expect(page).to have_button("Select")
    expect(page).to have_link("Edit")

    click_button("Select")

    expect(page).to have_link("Cancel")
    expect(page).not_to have_link("Edit")
    expect(page).not_to have_button("Select")
    expect(URI.parse(current_url).query).to include("select=true")
  end

  it "selects and deselects an image in select mode", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery, select: true))

    thumbnail = find("[data-image-id='#{image.id}']")
    expect(thumbnail).not_to match_css(".gallery-image--selected")

    thumbnail.click

    thumbnail = find("[data-image-id='#{image.id}']")
    expect(thumbnail).to match_css(".gallery-image--selected")
    expect(URI.parse(current_url).query).to include(
      "selected_ids%5B%5D=#{image.id}"
    )

    thumbnail.click

    thumbnail = find("[data-image-id='#{image.id}']")
    expect(thumbnail).not_to match_css(".gallery-image--selected")
    expect(URI.parse(current_url).query.to_s).not_to include(
      "selected_ids%5B%5D=#{image.id}"
    )
  end

  it "preserves tag filter and selection after page refresh", :js do
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
      match_css(".gallery-image--selected")
    )

    page.refresh

    expect(page).to have_css("[data-image-id='#{tagged_image.id}']")
    expect(page).not_to have_css(
      "[data-image-id='#{untagged_image.id}']"
    )
    expect(find("[data-image-id='#{tagged_image.id}']")).to(
      match_css(".gallery-image--selected")
    )
  end

  it "preserves selection when navigating between pages", :js do
    stub_const("GalleriesController::PER_PAGE", 1)
    user = create(:user)
    gallery = create(:gallery, user:)
    image1, image2 = create_pair(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    # images are ordered created_at desc, so image2 is on page 1
    visit(gallery_path(gallery))

    click_on("Next ›")
    wait_for_turbo
    click_button("Select")
    wait_for_turbo
    expect(page).to have_link("Cancel")

    expect(page).to have_css("[data-image-id='#{image1.id}']")
    find("[data-image-id='#{image1.id}']").click
    expect(find("[data-image-id='#{image1.id}']")).to(
      match_css(".gallery-image--selected")
    )

    click_on("‹ Prev")

    expect(page).to have_css("[data-image-id='#{image2.id}']")
    expect(URI.parse(current_url).query).to include(
      "selected_ids%5B%5D=#{image1.id}"
    )

    click_on("Next ›")

    expect(find("[data-image-id='#{image1.id}']")).to(
      match_css(".gallery-image--selected")
    )
  end

  it "bulk tags selected images", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:, name: "nature")
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery, select: true))

    find("[data-image-id='#{image.id}']").click
    expect(find("[data-image-id='#{image.id}']")).to(
      match_css(".gallery-image--selected")
    )

    click_on("Add tag")

    within(find("dialog[open]")) do
      fill_in("tag_search[query]", with: "nat")
      expect(page).to have_button("nature")
      click_button("nature")
      expect(page).to have_text("nature")
      click_button("Add tag")
    end

    expect(page).to have_current_path(
      gallery_path(gallery, select: true, selected_ids: [image.id])
    )
    expect(page).to have_link("Cancel")
    expect(page).to have_content("Tag added to selected images")
    expect(image.reload.tags).to include(tag)
  end

  it "preserves selection after bulk tagging", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    create(:galleries_tag, gallery:, name: "nature")
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery, select: true))

    find("[data-image-id='#{image.id}']").click
    expect(find("[data-image-id='#{image.id}']")).to(
      match_css(".gallery-image--selected")
    )

    click_on("Add tag")

    within(find("dialog[open]")) do
      fill_in("tag_search[query]", with: "nat")
      expect(page).to have_button("nature")
      click_button("nature")
      click_button("Add tag")
    end

    expect(page).to have_text("Tag added to selected images")

    expect(find("[data-image-id='#{image.id}']")).to(
      match_css(".gallery-image--selected")
    )
  end

  it "cancels select mode and clears selection", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery, select: true))

    find("[data-image-id='#{image.id}']").click
    expect(find("[data-image-id='#{image.id}']")).to(
      match_css(".gallery-image--selected")
    )

    click_on("Cancel")

    expect(page).to have_link("Edit")
    expect(page).not_to have_link("Cancel")
    query = URI.parse(current_url).query.to_s
    expect(query).not_to include("select")
    expect(query).not_to include("selected_ids")
    expect(find("[data-image-id='#{image.id}']")).not_to(
      match_css(".gallery-image--selected")
    )
  end

  it "does not include page param when bulk tagging on page 1", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    create(:galleries_tag, gallery:, name: "nature")
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery, select: true))

    find("[data-image-id='#{image.id}']").click

    click_on("Add tag")

    within(find("dialog[open]")) do
      fill_in("tag_search[query]", with: "nat")
      expect(page).to have_button("nature")
      click_button("nature")
      click_button("Add tag")
    end

    expect(page).to have_content("Tag added to selected images")
    expect(current_url).not_to include("page=")
  end

  it "preserves page when bulk tagging on page 2", :js do
    stub_const("GalleriesController::PER_PAGE", 1)
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:, name: "nature")
    # images are ordered created_at desc, so image1 is on page 2
    image1, _image2 = create_pair(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery))
    click_on("Next ›")
    wait_for_turbo
    click_button("Select")
    wait_for_turbo

    find("[data-image-id='#{image1.id}']").click
    expect(find("[data-image-id='#{image1.id}']")).to(
      match_css(".gallery-image--selected")
    )

    click_on("Add tag")

    within(find("dialog[open]")) do
      fill_in("tag_search[query]", with: "nat")
      expect(page).to have_button("nature")
      click_button("nature")
      click_button("Add tag")
    end

    expect(page).to have_content("Tag added to selected images")
    expect(page).to have_current_path(
      gallery_path(
        gallery,
        select: true,
        selected_ids: [image1.id],
        page: 2
      )
    )
    expect(image1.reload.tags).to include(tag)
  end

  it "preserves page when removing a tag filter in select mode", :js do
    stub_const("GalleriesController::PER_PAGE", 1)
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:, name: "nature")
    # images are ordered created_at desc, so image1 is on page 2
    image1, image2 = create_pair(
      :galleries_image,
      :with_real_file,
      gallery:
    )
    create(:galleries_image_tag, image: image1, tag:)
    create(:galleries_image_tag, image: image2, tag:)
    login_as(user)

    visit(gallery_path(gallery, tag_ids: [tag.id]))
    click_on("Next ›")
    wait_for_turbo
    click_button("Select")
    wait_for_turbo

    find("[data-image-id='#{image1.id}']").click
    expect(find("[data-image-id='#{image1.id}']")).to(
      match_css(".gallery-image--selected")
    )

    find("[data-role='tag-filter-remove-button']").click
    wait_for_turbo

    expect(page).to have_current_path(
      /page=2/
    )
  end

  it "preserves page when adding a tag filter in select mode", :js do
    stub_const("GalleriesController::PER_PAGE", 1)
    user = create(:user)
    gallery = create(:gallery, user:)
    create(:galleries_tag, gallery:, name: "nature")
    # images are ordered created_at desc, so image1 is on page 2
    image1, _image2 = create_pair(
      :galleries_image,
      :with_real_file,
      gallery:
    )
    login_as(user)

    visit(gallery_path(gallery))
    click_on("Next ›")
    wait_for_turbo
    click_button("Select")
    wait_for_turbo

    find("[data-image-id='#{image1.id}']").click
    expect(find("[data-image-id='#{image1.id}']")).to(
      match_css(".gallery-image--selected")
    )

    fill_in("tag_search[query]", with: "nat")
    expect(page).to have_css("[data-role='gallery-tag-search-result']")
    click_link("Add")
    wait_for_turbo

    expect(page).to have_current_path(
      /page=2/
    )
  end
end
