require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownloadRowComponent,
  type: :component do
  it "renders the source url as an external link" do
    download = build_stubbed(
      :galleries_remote_video_download,
      status: "pending",
      url: "https://example.com/clip.mp4"
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "a[href='https://example.com/clip.mp4'][target='_blank']",
      text: "https://example.com/clip.mp4"
    )
  end

  it "renders the status pill" do
    download = build_stubbed(
      :galleries_remote_video_download,
      status: "downloading"
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css("span.bg-blue-100", text: "downloading")
  end

  it "shows a placeholder when not completed" do
    download = build_stubbed(
      :galleries_remote_video_download,
      status: "pending"
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css("[data-role=thumbnail-placeholder]")
    expect(page).to have_no_css("img")
  end

  it "links to the resulting image when completed" do
    download = create(:galleries_remote_video_download, :completed)

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css("a[data-role=image-thumbnail]")
    expect(page).to have_css("img")
    expect(page).to have_no_css("[data-role=thumbnail-placeholder]")
  end

  it "shows the error message when failed" do
    download = build_stubbed(
      :galleries_remote_video_download,
      :failed
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "[data-role=error-message]",
      text: "unable to download video"
    )
  end
end
