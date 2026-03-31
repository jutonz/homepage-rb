require "rails_helper"

RSpec.describe Galleries::ImageVariantJob do
  describe "#perform" do
    it "genreates a variant for the image" do
      image = create(:galleries_image, :with_real_file)
      variant = image.file.variant(:thumb)

      described_class.new.perform(image)

      expect(variant.blob).to be_present
    end

    it "does nothing if the file is not variable" do
      image = create(
        :galleries_image,
        file: Rack::Test::UploadedFile.new(
          fixture_file_upload("testing.pdf")
        )
      )

      expect {
        described_class.new.perform(image)
      }.not_to raise_error
    end

    it "sets processing to false after generating the variant" do
      image = create(
        :galleries_image,
        :with_real_file,
        processing: true
      )

      described_class.new.perform(image)

      expect(image.reload.processing).to be(false)
    end

    it "broadcasts a turbo stream replacing the image card" do
      image = create(:galleries_image, :with_real_file, processing: true)
      expected_target = ActionView::RecordIdentifier.dom_id(image, :card)

      # Turbo broadcasts to the raw GID param, not the prefixed channel stream
      expect {
        described_class.new.perform(image)
      }.to have_broadcasted_to(image.to_gid_param)
        .with(a_string_including(expected_target))
    end
  end
end
