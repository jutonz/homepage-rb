require "rails_helper"

RSpec.describe "Active Storage configuration" do
  it "makes video posters with the streaming previewer" do
    previewers = ActiveStorage.previewers

    expect(previewers).to include(StreamingVideoPreviewer)
    expect(previewers)
      .not_to include(ActiveStorage::Previewer::VideoPreviewer)
  end

  it "keeps the PDF previewers" do
    previewers = ActiveStorage.previewers

    expect(previewers).to include(
      ActiveStorage::Previewer::PopplerPDFPreviewer,
      ActiveStorage::Previewer::MuPDFPreviewer
    )
  end

  it "does not analyze videos" do
    image = create(:galleries_image, :webm)
    blob = image.file.blob
    allow(blob).to receive(:open).and_call_original

    blob.analyze

    expect(blob).not_to have_received(:open)
    expect(blob.metadata).not_to include("duration")
  end
end
