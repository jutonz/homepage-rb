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
        image.gallery
          .processing_images_stream_name,
        target:
          "processing_image_#{image.id}"
      )
  end

  it "processes a poster preview for previewable (video) files" do
    image = create(:galleries_image, :webm)
    poster = instance_double(ActiveStorage::Preview)
    allow(image).to receive(:poster).and_return(poster)
    allow(Turbo::StreamsChannel).to receive(:broadcast_remove_to)
    expect(poster).to receive(:processed)

    described_class.new.perform(image)
  end
end

RSpec.describe Galleries::ImageProcessingJob, "concurrency" do
  it "runs one video poster at a time" do
    first_video = build(:galleries_image, :webm)
    second_video = build(:galleries_image, :webm)

    first_key = described_class.new(first_video).concurrency_key
    second_key = described_class.new(second_video).concurrency_key

    expect(first_key).to eq(second_key)
    expect(described_class.concurrency_limit).to eq(1)
  end

  it "does not hold still images behind video posters" do
    video = build(:galleries_image, :webm)
    first_image = build_stubbed(:galleries_image)
    second_image = build_stubbed(:galleries_image)

    keys = [video, first_image, second_image].map do |image|
      described_class.new(image).concurrency_key
    end

    expect(keys.uniq.size).to eq(3)
  end

  it "holds the lock longer than the default period" do
    duration = described_class.concurrency_duration

    expect(duration).to eq(15.minutes)
  end
end
