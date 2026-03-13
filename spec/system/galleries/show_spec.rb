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

  it "navigates to image show page when not in select mode", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_path(gallery))

    find("[data-image-id='#{image.id}']").click

    expect(page).to have_current_path(
      gallery_image_path(gallery, image)
    )
  end
end
