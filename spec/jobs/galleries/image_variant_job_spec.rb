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
  end
end
