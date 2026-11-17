require "rails_helper"

RSpec.describe StreamingVideoPreviewer do
  describe ".accept?" do
    it "accepts a video" do
      image = create(:galleries_image, :webm)

      expect(described_class.accept?(image.file.blob)).to be(true)
    end
  end

  describe "#preview" do
    it "yields a JPEG poster with the given options" do
      image = create(:galleries_image, :webm)
      previewer = described_class.new(image.file.blob)
      attachable = nil
      magic_bytes = nil

      previewer.preview(service_name: "test") do |yielded|
        attachable = yielded
        magic_bytes = yielded[:io].read(3).bytes
      end

      expect(attachable).to include(
        filename: "video.jpg",
        content_type: "image/jpeg",
        service_name: "test"
      )
      expect(magic_bytes).to eq([0xFF, 0xD8, 0xFF])
    end

    it "reads the video in place instead of downloading it" do
      image = create(:galleries_image, :webm)
      blob = image.file.blob
      allow(blob).to receive(:open).and_call_original
      allow(blob).to receive(:download).and_call_original

      described_class.new(blob).preview {}

      expect(blob).not_to have_received(:open)
      expect(blob).not_to have_received(:download)
    end

    it "gives ffmpeg the blob URL for a remote service" do
      image = create(:galleries_image, :webm)
      blob = image.file.blob
      url = "https://storage.example/video.webm?signature=abc"
      allow(blob).to receive_messages(
        service: instance_double(ActiveStorage::Service),
        url:
      )
      previewer = described_class.new(blob)
      ffmpeg_args = []
      allow(previewer).to receive(:draw) { |*args| ffmpeg_args = args }

      previewer.preview {}

      expect(ffmpeg_args.first).to eq(described_class.ffmpeg_path)
      expect(ffmpeg_args.each_cons(2)).to include(["-i", url])
    end
  end
end
