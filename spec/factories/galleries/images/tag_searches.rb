FactoryBot.define do
  factory :galleries_tag_search, class: "Galleries::TagSearch" do
    skip_create
    gallery factory: :gallery

    trait :with_image do
      image { build(:galleries_image, gallery: instance.gallery) }
    end
  end
end
