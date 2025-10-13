# == Schema Information
#
# Table name: galleries_image_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image_id   :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_galleries_image_tags_on_image_id                 (image_id)
#  index_galleries_image_tags_on_image_id_and_created_at  (image_id,created_at)
#  index_galleries_image_tags_on_tag_id                   (tag_id)
#  index_galleries_image_tags_on_tag_id_and_image_id      (tag_id,image_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (image_id => galleries_images.id)
#  fk_rails_...  (tag_id => galleries_tags.id)
#
require "rails_helper"

RSpec.describe Galleries::ImageTag do
  it { is_expected.to belong_to(:image) }
  it { is_expected.to belong_to(:tag) }

  it do
    expect(build(:galleries_image_tag))
      .to validate_uniqueness_of(:tag)
      .scoped_to(:image_id)
  end
end
