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

RSpec.describe Galleries::Image do
  it { is_expected.to belong_to(:gallery) }
  it { is_expected.to validate_presence_of(:file) }

  it "has a valid factory" do
    expect(create(:galleries_image)).to be_valid
  end
end
