require "rails_helper"

RSpec.describe "Gallery processing images" do
  it "removes images when processing completes", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    login_as(user)

    visit(gallery_processing_images_path(gallery))

    expect(page).to have_css(
      "#processing_image_#{image.id}"
    )

    Galleries::ImageProcessingJob.perform_now(image)

    expect(page).not_to have_css(
      "#processing_image_#{image.id}"
    )
  end
end
