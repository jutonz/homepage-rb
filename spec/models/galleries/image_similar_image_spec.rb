require "rails_helper"

RSpec.describe Galleries::ImageSimilarImage do
  it { is_expected.to belong_to(:parent_image) }
  it { is_expected.to belong_to(:image) }

  describe "uniqueness" do
    subject { build(:galleries_image_similar_image) }

    it "validates uniqueness of position in scope" do
      is_expected.to validate_uniqueness_of(:position).scoped_to(:parent_image_id)
    end
  end
end
