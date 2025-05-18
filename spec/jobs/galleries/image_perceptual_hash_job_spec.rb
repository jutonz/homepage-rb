require "rails_helper"

RSpec.describe Galleries::ImagePerceptualHashJob, "#perform" do
  it "calls Image#calculate_perceptual_hash!" do
    image = build(:galleries_image)
    expect(image).to receive(:calculate_perceptual_hash!)
    described_class.new.perform(image)
  end
end
