# == Schema Information
#
# Table name: galleries_social_media_links
#
#  id         :bigint           not null, primary key
#  platform   :string           not null
#  username   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_galleries_social_media_links_on_platform_and_username  (platform,username) UNIQUE
#  index_galleries_social_media_links_on_tag_id                 (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (tag_id => galleries_tags.id)
#
require "rails_helper"

RSpec.describe Galleries::SocialMediaLink do
  it { is_expected.to belong_to(:tag) }

  it { is_expected.to validate_presence_of(:platform) }
  it { is_expected.to validate_presence_of(:username) }

  describe "username uniqueness" do
    subject { build(:galleries_social_media_link) }
    it { is_expected.to validate_uniqueness_of(:username).scoped_to(:platform) }
  end

  it "has a valid factory" do
    expect(build(:galleries_social_media_link)).to be_valid
  end
end
