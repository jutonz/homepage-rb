require "rails_helper"

RSpec.describe Galleries::BulkUploadSelectedTagComponent,
  type: :component do
  it "wraps the pill in a turbo frame with the given id" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(
        tag:,
        frame_id: "bulk-upload-tag-#{tag.id}"
      )
    )

    expect(page).to have_css(
      "turbo-frame#bulk-upload-tag-#{tag.id}"
    )
    expect(page).to have_css("turbo-frame[data-role='tag']")
  end

  it "renders the tag display name" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(tag:, frame_id: "bulk-upload-tag-1")
    )

    expect(page).to have_text(tag.display_name)
  end

  it "renders a remove link at the bulk upload tag path" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(tag:, frame_id: "bulk-upload-tag-1")
    )

    expect(page).to have_link(
      "×",
      href: gallery_bulk_upload_tag_path(tag.gallery, tag)
    )
  end

  it "labels the remove link with the tag name" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(tag:, frame_id: "bulk-upload-tag-1")
    )

    expect(page).to have_css(
      "a[aria-label='Remove landscapes']"
    )
  end

  it "issues the remove link as a turbo DELETE" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(tag:, frame_id: "bulk-upload-tag-1")
    )

    expect(page).to have_css("a[data-turbo-method='delete']")
  end
end
