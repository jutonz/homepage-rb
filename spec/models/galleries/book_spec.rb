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
end
