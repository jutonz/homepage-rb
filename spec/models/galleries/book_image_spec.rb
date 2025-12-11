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
require "rails_helper"

RSpec.describe Galleries::BookImage do
  it { is_expected.to belong_to(:book) }
  it { is_expected.to belong_to(:image) }
  it { is_expected.to validate_presence_of(:order) }

  it do
    expect(build(:galleries_book_image))
      .to validate_uniqueness_of(:image)
      .scoped_to(:book_id)
  end
end
