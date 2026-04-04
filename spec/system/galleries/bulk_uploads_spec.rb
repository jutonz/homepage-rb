require "rails_helper"

RSpec.describe "Gallery bulk uploads",
  type: :system do
  it "shows file list and supports removal",
    :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)
    file = Rails.root.join(
      "spec/fixtures/files/audiosurf.jpg"
    )

    visit(new_gallery_bulk_upload_path(gallery))

    # Dropzone instructions are visible
    expect(page).to have_content(
      "Drag images here or click to browse"
    )

    # Select files
    attach_file(
      "bulk_upload[files][]",
      [file, file],
      make_visible: true
    )

    # File rows appear
    expect(page).to have_css(
      ".dropzone__file-row", count: 2
    )
    expect(page).to have_content("audiosurf.jpg")

    # Remove one file
    first(
      "[data-remove-btn]"
    ).click

    # Only one row remains
    expect(page).to have_css(
      ".dropzone__file-row", count: 1
    )
  end

  it "accumulates files across selections",
    :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)
    jpg = Rails.root.join(
      "spec/fixtures/files/audiosurf.jpg"
    )
    webm = Rails.root.join(
      "spec/fixtures/files/video.webm"
    )

    visit(new_gallery_bulk_upload_path(gallery))

    # First selection
    attach_file(
      "bulk_upload[files][]",
      [jpg],
      make_visible: true
    )
    expect(page).to have_css(
      ".dropzone__file-row", count: 1
    )

    # Second selection adds to the list
    attach_file(
      "bulk_upload[files][]",
      [webm],
      make_visible: true
    )
    expect(page).to have_css(
      ".dropzone__file-row", count: 2
    )
    expect(page).to have_content("audiosurf.jpg")
    expect(page).to have_content("video.webm")
  end

  it "uploads files with tags applied", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    create(
      :galleries_tag,
      gallery:,
      name: "landscapes"
    )
    login_as(user)
    file = Rails.root.join(
      "spec/fixtures/files/audiosurf.jpg"
    )

    visit(new_gallery_bulk_upload_path(gallery))

    # Select a file
    attach_file(
      "bulk_upload[files][]",
      [file],
      make_visible: true
    )
    expect(page).to have_css(
      ".dropzone__file-row", count: 1
    )

    # Search for and add a tag
    fill_in(
      "Tag search query",
      with: "landscapes"
    )
    wait_for_turbo
    click_button("Add tag")
    wait_for_turbo

    expect(page).to have_content("landscapes")

    # Submit the form
    click_button("Create Bulk upload")

    expect(page).to have_current_path(
      gallery_processing_images_path(gallery)
    )
    expect(page).to have_content(
      "Bulk upload successful"
    )

    # Verify image was created with tag
    image = gallery.images.last
    expect(image).to be_present
    expect(
      image.tags.pluck(:name)
    ).to include("landscapes")
  end
end
