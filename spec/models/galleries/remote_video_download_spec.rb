require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownload do
  it { is_expected.to belong_to(:gallery) }
  it { is_expected.to belong_to(:image).optional }

  it { is_expected.to validate_presence_of(:url) }

  it {
    is_expected.to define_enum_for(:status)
      .with_values(
        pending: "pending",
        downloading: "downloading",
        completed: "completed",
        failed: "failed"
      )
      .backed_by_column_of_type(:enum)
      .with_prefix(:status)
  }

  it "has a valid factory" do
    expect(build(:galleries_remote_video_download)).to be_valid
  end

  it "broadcasts a replace of its row to the gallery stream" do
    rvd = build_stubbed(:galleries_remote_video_download)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

    rvd.broadcast_row

    expect(Turbo::StreamsChannel)
      .to have_received(:broadcast_replace_to)
      .with(
        rvd.gallery.remote_video_downloads_stream_name,
        target: "remote_video_download_#{rvd.id}",
        partial: "galleries/remote_video_downloads/row",
        locals: {remote_video_download: rvd}
      )
  end

  it "swallows broadcast errors so callers are unaffected" do
    rvd = build_stubbed(:galleries_remote_video_download)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      .and_raise(StandardError.new("boom"))

    expect { rvd.broadcast_row }.not_to raise_error
  end
end
