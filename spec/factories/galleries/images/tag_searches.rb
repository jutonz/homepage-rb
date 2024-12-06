FactoryBot.define do
  factory :galleries_images_tag_search, class: "Galleries::Images::TagSearch" do
    skip_create

    image factory: :galleries_image
    gallery { instance.image.gallery }
  end
end
