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

  it "renders the created at timestamp" do
    download = build_stubbed(
      :galleries_remote_video_download,
      created_at: Time.zone.local(2026, 6, 27, 14, 14)
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "[data-role=created-at]",
      text: "June 27, 2026 14:14"
    )
  end

  it "gives the row a stable dom id" do
    download = build_stubbed(:galleries_remote_video_download)

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "#remote_video_download_#{download.id}"
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

  it "renders a retry button with a confirmation when failed" do
    download = build_stubbed(:galleries_remote_video_download, :failed)

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "form[action='" \
      "#{gallery_remote_video_download_retries_path(
        download.gallery, download
      )}'] button[data-turbo-confirm='Re-run this download?']",
      text: "Retry"
    )
  end

  it "renders a retry button when not failed" do
    download = build_stubbed(
      :galleries_remote_video_download, status: "downloading"
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_button("Retry")
  end

  it "renders a delete button with a confirmation for every status" do
    download = build_stubbed(
      :galleries_remote_video_download, status: "downloading"
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_css(
      "form[action='" \
      "#{gallery_remote_video_download_path(
        download.gallery, download
      )}'] button[data-turbo-confirm='Delete this video download?']",
      text: "Delete"
    )
  end

  it "renders an edit link pointing at the edit page for every status" do
    download = build_stubbed(
      :galleries_remote_video_download, status: "downloading"
    )

    render_inline(described_class.new(remote_video_download: download))

    expect(page).to have_link(
      "Edit",
      href: edit_gallery_remote_video_download_path(
        download.gallery, download
      )
    )
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
