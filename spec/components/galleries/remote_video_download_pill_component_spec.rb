require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownloadPillComponent,
  type: :component do
  it "renders a gray pill for pending status" do
    download = build_stubbed(
      :galleries_remote_video_download,
      status: "pending"
    )
    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "span.bg-gray-100.text-gray-800",
      text: "pending"
    )
  end

  it "renders a blue pill for downloading status" do
    download = build_stubbed(
      :galleries_remote_video_download,
      status: "downloading"
    )
    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "span.bg-blue-100.text-blue-800",
      text: "downloading"
    )
  end

  it "renders a green pill for completed status" do
    download = build_stubbed(
      :galleries_remote_video_download,
      status: "completed"
    )
    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "span.bg-green-100.text-green-800",
      text: "completed"
    )
  end

  it "renders a red pill for failed status" do
    download = build_stubbed(
      :galleries_remote_video_download,
      status: "failed"
    )
    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "span.bg-red-100.text-red-800",
      text: "failed"
    )
  end
end
