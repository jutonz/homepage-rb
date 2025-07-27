# == Schema Information
#
# Table name: galleries
#
#  id           :bigint           not null, primary key
#  hidden_at    :datetime
#  images_count :integer          default(0), not null
#  name         :string           not null
#  tags_count   :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_galleries_on_name     (name) UNIQUE
#  index_galleries_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Gallery do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:images) }
  it { is_expected.to have_many(:tags) }

  it { is_expected.to validate_presence_of(:name) }

  describe "uniqueness validation" do
    subject { build(:gallery) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  it "has a valid factory" do
    expect(create(:gallery)).to be_valid
  end

  describe ".visible" do
    it "does not include hidden galleries" do
      visible = create(:gallery)
      _hidden = create(:gallery, :hidden)

      result = described_class.visible.pluck(:id)

      expect(result).to eql([visible.id])
    end
  end

  describe ".hidden" do
    it "only includes hidden galleries" do
      _visible = create(:gallery)
      hidden = create(:gallery, :hidden)

      result = described_class.hidden.pluck(:id)

      expect(result).to eql([hidden.id])
    end
  end

  describe "#recently_used_tags" do
    it "calls the query object" do
      allow(Galleries::RecentTagsQuery).to receive(:call)
      gallery = build(:gallery)

      gallery.recently_used_tags

      expect(Galleries::RecentTagsQuery)
        .to have_received(:call)
        .with(
          gallery:,
          excluded_image_ids: nil,
          image_limit: 10
        )
    end
  end
end
