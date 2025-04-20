FactoryBot.define do
  factory :galleries_image_similar_image, class: "Galleries::ImageSimilarImage" do
    image factory: :galleries_image
    parent_image factory: :galleries_image
    sequence(:position) { it }
  end
end
