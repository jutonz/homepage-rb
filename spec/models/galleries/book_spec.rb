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
#  index_galleries_books_on_gallery_id_and_lower_name  (gallery_id, lower((name)::text)) UNIQUE
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
  it do
    expect(build(:galleries_book))
      .to validate_uniqueness_of(:name)
      .scoped_to(:gallery_id)
      .case_insensitive
  end
  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it do
    is_expected.to normalize(:name)
      .from("  Summer \t trip \n")
      .to("Summer trip")
  end

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

  describe "name index" do
    it "rejects a duplicate name that skips validation" do
      gallery = create(:gallery)
      create(:galleries_book, gallery:, name: "Trip")
      book = create(:galleries_book, gallery:, name: "Other")

      expect { book.update_column(:name, "TRIP") }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows the same name in another gallery" do
      create(:galleries_book, name: "Trip")
      book = create(:galleries_book, name: "Other")

      book.update_column(:name, "TRIP")

      expect(book.reload.name).to eql("TRIP")
    end
  end
end
