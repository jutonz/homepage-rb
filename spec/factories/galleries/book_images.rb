# == Schema Information
#
# Table name: galleries_book_images
# Database name: primary
#
#  id         :bigint           not null, primary key
#  order      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint           not null
#  image_id   :bigint           not null
#
# Indexes
#
#  index_galleries_book_images_on_book_id               (book_id)
#  index_galleries_book_images_on_book_id_and_image_id  (book_id,image_id) UNIQUE
#  index_galleries_book_images_on_image_id              (image_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => galleries_books.id)
#  fk_rails_...  (image_id => galleries_images.id)
#
FactoryBot.define do
  factory :galleries_book_image, class: "Galleries::BookImage" do
    book factory: :galleries_book
    image factory: :galleries_image
    sequence(:order) { it }
  end
end
