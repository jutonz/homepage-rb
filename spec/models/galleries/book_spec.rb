# == Schema Information
#
# Table name: galleries_books
# Database name: primary
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#
# Indexes
#
#  index_galleries_books_on_gallery_id  (gallery_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#
require "rails_helper"

RSpec.describe Galleries::Book do
  it { is_expected.to belong_to(:gallery) }
  it { is_expected.to have_many(:book_images).dependent(:destroy) }
  it { is_expected.to have_many(:images).through(:book_images) }
  it { is_expected.to validate_presence_of(:name) }

  describe "#images" do
    it "is ordered by order" do
      gallery = create(:gallery)
      book = create(:galleries_book, gallery:)
      image1, image2 = create_pair(:galleries_image, gallery:)
      create(:galleries_book_image, book:, image: image1, order: 2)
      create(:galleries_book_image, book:, image: image2, order: 1)

      expect(book.images.pluck(:id)).to eql([image2.id, image1.id])
    end
  end
end
