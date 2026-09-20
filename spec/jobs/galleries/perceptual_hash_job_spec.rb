require "rails_helper"

RSpec.describe Galleries::PerceptualHashJob, "#perform" do
  it "writes a hash to the image" do
    image = create(:galleries_image, :with_real_file)

    described_class.new.perform(image)

    expect(image.reload.perceptual_hash).to be_present
  end

  it "leaves processed_at alone" do
    image = create(
      :galleries_image,
      :with_real_file,
      processed_at: 1.week.ago
    )
    was_processed_at = image.processed_at

    described_class.new.perform(image)

    expect(image.reload.processed_at)
      .to be_within(1.second).of(was_processed_at)
  end

  it "does not broadcast to the processing stream" do
    image = create(:galleries_image, :with_real_file)
    allow(Turbo::StreamsChannel).to receive(:broadcast_remove_to)

    described_class.new.perform(image)

    expect(Turbo::StreamsChannel)
      .not_to have_received(:broadcast_remove_to)
  end
end
