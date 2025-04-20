require "rails_helper"

RSpec.describe Galleries::UpdateSimilarImagesJob, "#perform" do
  it "calls Gallerie::UpdateSimilarImages" do
    image = build(:galleries_image)
    expect(Galleries::UpdateSimilarImages)
      .to receive(:call)
      .with(image:)

    described_class.new.perform(image)
  end
end
