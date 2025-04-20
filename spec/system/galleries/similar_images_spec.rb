require "rails_helper"

RSpec.describe "Gallery similar images" do
  it "paginates similar images" do
    user = create(:user)
    gallery = create(:gallery, user:)
    image1, image2, image3 = create_list(:galleries_image, 3, gallery:)
    [image2, image3].each do |image|
      create(:galleries_image_similar_image, parent_image: image1, image:)
    end
    login_as(user)
    stub_const("Galleries::SimilarImagesComponent::PER_PAGE", 1)

    visit(gallery_image_path(gallery, image1))

    within("[data-role=similar-images]") do
      expect(page).to have_css("[data-image-id=#{image2.id}]")
      expect(page).not_to have_css("[data-image-id=#{image3.id}]")

      click_on("Next")

      expect(page).to have_css("[data-image-id=#{image3.id}]")
      expect(page).not_to have_css("[data-image-id=#{image2.id}]")

      click_on("Previous")

      expect(page).to have_css("[data-image-id=#{image2.id}]")
      expect(page).not_to have_css("[data-image-id=#{image3.id}]")
    end
  end
end
