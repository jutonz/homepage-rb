require "rails_helper"

RSpec.describe "Gallery processing images" do
  it "removes images when processing completes", :js, :real_cable do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(
      :galleries_image,
      :unprocessed,
      :with_real_file,
      gallery:
    )
    login_as(user)

    visit(gallery_processing_images_path(gallery))

    expect(page).to have_css("[data-role=processing-image]")

    Galleries::ImageProcessingJob.perform_now(image)

    expect(page).not_to have_css("[data-role=processing-image]")
  end

  it "reconciles when a broadcast is missed", :js, :real_cable do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(
      :galleries_image,
      :unprocessed,
      :with_real_file,
      gallery:
    )
    login_as(user)

    visit(gallery_processing_images_path(gallery))

    expect(page).to have_css("[data-role=processing-image]")

    image.update!(processed_at: Time.current)

    expect(page).not_to have_css("[data-role=processing-image]")
  end
end
