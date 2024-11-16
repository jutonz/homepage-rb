# == Schema Information
#
# Table name: galleries_tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_galleries_tags_on_gallery_id           (gallery_id)
#  index_galleries_tags_on_gallery_id_and_name  (gallery_id,name) UNIQUE
#  index_galleries_tags_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Galleries::Tag, type: :model do
  it { is_expected.to belong_to(:gallery) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:name) }
  it do
    expect(build(:galleries_tag))
      .to validate_uniqueness_of(:name)
      .scoped_to(:gallery_id)
  end
end
