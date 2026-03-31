require "rails_helper"

RSpec.describe "Gallery bulk uploads", type: :system do
  it "uploads images and shows processing cards", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)

    visit(new_gallery_bulk_upload_path(gallery))

    attach_file(
      "Files",
      Rails.root.join("spec/fixtures/files/audiosurf.jpg")
    )
    click_button("Create Bulk upload")

    expect(page).to have_css(
      "[data-role=processing-image-card]",
      wait: 10
    )
    expect(gallery.images.count).to eq(1)
  end
end
