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
require "rails_helper"

RSpec.describe Image do
  it { is_expected.to belong_to(:gallery) }

  it "has a valid factory" do
    expect(create(:image)).to be_valid
  end
end