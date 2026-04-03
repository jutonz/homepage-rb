require "rails_helper"

RSpec.describe Galleries::ImageProcessingJob, "#perform" do
  it "generates a thumb variant for the image" do
    image = create(:galleries_image, :with_real_file)
    variant = image.file.variant(:thumb)

    described_class.new.perform(image)

    expect(variant.blob).to be_present
  end

  it "calculates the perceptual hash" do
    image = create(:galleries_image, :with_real_file)
    expect(image).to receive(:calculate_perceptual_hash!)

    described_class.new.perform(image)
  end

  it "skips variant generation for non-variable files" do
    image = create(:galleries_image, :with_real_file)
    allow(image.file).to receive(:variable?).and_return(false)
    expect(image).to receive(:calculate_perceptual_hash!)

    described_class.new.perform(image)
  end

  it "sets processed_at on the image" do
    image = create(:galleries_image, :with_real_file)

    freeze_time do
      described_class.new.perform(image)

      expect(image.reload.processed_at)
        .to eq(Time.current)
    end
  end

  it "broadcasts removal from processing page" do
    image = create(
      :galleries_image, :with_real_file
    )
    allow(Turbo::StreamsChannel)
      .to receive(:broadcast_remove_to)

    described_class.new.perform(image)

    expect(Turbo::StreamsChannel)
      .to have_received(:broadcast_remove_to)
      .with(
        "gallery_#{image.gallery_id}" \
          "_processing_images",
        target:
          "processing_image_#{image.id}"
      )
  end
end
