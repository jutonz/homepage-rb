require "rails_helper"

RSpec.describe "Gallery bulk uploads", type: :system do
  it "shows the dropzone, accumulates selected files, and " \
    "removes them on demand", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)
    jpg = Rails.root.join("spec/fixtures/files/audiosurf.jpg")
    webm = Rails.root.join("spec/fixtures/files/video.webm")

    visit(new_gallery_bulk_upload_path(gallery))

    expect(page).to have_content(
      "Drag images here or click to browse"
    )

    attach_file(
      "bulk_upload[files][]",
      [jpg],
      make_visible: true
    )
    expect(page).to have_css(".dropzone__file-row", count: 1)
    expect(page).to have_content("audiosurf.jpg")

    attach_file(
      "bulk_upload[files][]",
      [webm],
      make_visible: true
    )
    expect(page).to have_css(".dropzone__file-row", count: 2)
    expect(page).to have_content("video.webm")

    first("[data-remove-btn]").click
    expect(page).to have_css(".dropzone__file-row", count: 1)
  end

  it "opens and closes the tag search modal via Done and " \
    "ESC", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)

    visit(new_gallery_bulk_upload_path(gallery))

    click_button("Add tags")
    expect(page).to have_css("dialog[open]")
    within("dialog[open]") { click_button("Done") }
    expect(page).to have_no_css("dialog[open]")

    click_button("Add tags")
    expect(page).to have_css("dialog[open]")
    find_field("Tag search query").send_keys(:escape)
    expect(page).to have_no_css("dialog[open]")
  end

  it "adds and removes tags through the modal, syncing both " \
    "displays", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    create(:galleries_tag, gallery:, name: "landscapes")
    create(:galleries_tag, gallery:, name: "portraits")
    login_as(user)

    visit(new_gallery_bulk_upload_path(gallery))
    click_button("Add tags")

    within("dialog[open]") do
      fill_in("Tag search query", with: "landscapes")
      wait_for_turbo
      expect(page).to have_content("landscapes")
      click_button("Add tag")
      wait_for_turbo
      fill_in("Tag search query", with: "portraits")
      wait_for_turbo
      click_button("Add tag")
      wait_for_turbo
    end

    expect(page).to have_css("dialog[open]")
    within("#bulk-upload-modal-selected-tags") do
      expect(page).to have_content("landscapes")
      expect(page).to have_content("portraits")
    end
    within("#bulk-upload-selected-tags") do
      expect(page).to have_content("landscapes")
      expect(page).to have_content("portraits")
    end

    within("#bulk-upload-modal-selected-tags") do
      click_link("Remove landscapes")
    end
    wait_for_turbo

    expect(page).to have_no_css(
      "#bulk-upload-modal-selected-tags",
      text: "landscapes"
    )
    expect(page).to have_no_css(
      "#bulk-upload-selected-tags",
      text: "landscapes"
    )
  end

  it "removes from the page panel and syncs into the modal", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    create(:galleries_tag, gallery:, name: "landscapes")
    login_as(user)

    visit(new_gallery_bulk_upload_path(gallery))
    click_button("Add tags")

    within("dialog[open]") do
      fill_in("Tag search query", with: "landscapes")
      wait_for_turbo
      click_button("Add tag")
      wait_for_turbo
      click_button("Done")
    end

    expect(page).to have_no_css("dialog[open]")

    within("#bulk-upload-selected-tags") do
      click_link("Remove landscapes")
    end
    wait_for_turbo

    expect(page).to have_no_css(
      "#bulk-upload-selected-tags",
      text: "landscapes"
    )

    click_button("Add tags")
    expect(page).to have_css("dialog[open]")
    expect(page).to have_no_css(
      "#bulk-upload-modal-selected-tags",
      text: "landscapes"
    )
  end

  it "uploads files with tags applied", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    create(:galleries_tag, gallery:, name: "landscapes")
    login_as(user)
    file = Rails.root.join("spec/fixtures/files/audiosurf.jpg")

    visit(new_gallery_bulk_upload_path(gallery))

    attach_file(
      "bulk_upload[files][]",
      [file],
      make_visible: true
    )
    expect(page).to have_css(".dropzone__file-row", count: 1)

    click_button("Add tags")
    within("dialog[open]") do
      fill_in("Tag search query", with: "landscapes")
      wait_for_turbo
      click_button("Add tag")
      wait_for_turbo
      click_button("Done")
    end

    expect(page).to have_no_css("dialog[open]")
    expect(page).to have_content("landscapes")

    click_button("Create Bulk upload")

    expect(page).to have_current_path(
      gallery_processing_images_path(gallery)
    )
    expect(page).to have_content("Bulk upload successful")

    image = gallery.images.last
    expect(image).to be_present
    expect(image.tags.pluck(:name)).to include("landscapes")
  end
end
