# == Schema Information
#
# Table name: galleries_social_media_links
# Database name: primary
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
  it { is_expected.to normalize(:username).from(" f ").to("f") }
  it { is_expected.to normalize(:username).from("F").to("f") }

  describe "username uniqueness" do
    subject { build(:galleries_social_media_link) }
    it do
      is_expected
        .to validate_uniqueness_of(:username)
        .scoped_to(:platform)
        .ignoring_case_sensitivity
    end
  end

  it "has a valid factory" do
    expect(build(:galleries_social_media_link)).to be_valid
  end

  describe "#href" do
    it "handles an instagram link" do
      link = build(:galleries_social_media_link, :instagram)
      expect(link.href).to eql("https://instagram.com/#{link.username}")
    end

    it "handles a reddit link" do
      link = build(:galleries_social_media_link, :reddit)
      expect(link.href).to eql("https://reddit.com/u/#{link.username}")
    end

    it "handles a tiktok link" do
      link = build(:galleries_social_media_link, :tiktok)
      expect(link.href).to eql("https://tiktok.com/@#{link.username}")
    end

    it "handles a url link" do
      link = build(:galleries_social_media_link, :url)
      expect(link.href).to eql(link.username)
    end

    it "is not blank for any supported platform" do
      link = build(:galleries_social_media_link)

      described_class.platforms.keys.each do |platform|
        link.platform = platform
        expect(link.href).to be_present
      end
    end
  end
end
