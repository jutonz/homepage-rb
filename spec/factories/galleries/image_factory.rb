# == Schema Information
#
# Table name: gallery_images
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#
# Indexes
#
#  index_gallery_images_on_gallery_id  (gallery_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#
FactoryBot.define do
  factory :image, class: "Image" do
    gallery
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/audiosurf.jpg"), "image/jpeg") }
  end
end
