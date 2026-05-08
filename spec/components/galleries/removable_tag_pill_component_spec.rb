require "rails_helper"

RSpec.describe Galleries::RemovableTagPillComponent,
  type: :component do
  it "wraps the pill in a turbo frame with the given id" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(
        tag:,
        frame_id: "bulk-upload-tag-#{tag.id}",
        remove_path: "/some/path"
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
      described_class.new(
        tag:,
        frame_id: "tag-1",
        remove_path: "/some/path"
      )
    )

    expect(page).to have_text(tag.display_name)
  end

  it "renders the remove link at the given path" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(
        tag:,
        frame_id: "tag-1",
        remove_path: "/galleries/1/bulk_upload_tags/#{tag.id}"
      )
    )

    expect(page).to have_link(
      "×",
      href: "/galleries/1/bulk_upload_tags/#{tag.id}"
    )
  end

  it "labels the remove link with the tag name" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(
        tag:,
        frame_id: "tag-1",
        remove_path: "/some/path"
      )
    )

    expect(page).to have_css(
      "a[aria-label='Remove landscapes']"
    )
  end

  it "issues the remove link as a turbo DELETE" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(
        tag:,
        frame_id: "tag-1",
        remove_path: "/some/path"
      )
    )

    expect(page).to have_css("a[data-turbo-method='delete']")
  end

  it "omits the turbo-confirm attribute by default" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(
        tag:,
        frame_id: "tag-1",
        remove_path: "/some/path"
      )
    )

    expect(page).to have_no_css("a[data-turbo-confirm]")
  end

  it "adds a turbo-confirm attribute when given" do
    tag = build_stubbed(:galleries_tag, name: "landscapes")

    render_inline(
      described_class.new(
        tag:,
        frame_id: "tag-1",
        remove_path: "/some/path",
        turbo_confirm: "Really remove tag 'landscapes'?"
      )
    )

    expect(page).to have_css(
      "a[data-turbo-confirm=\"Really remove tag 'landscapes'?\"]"
    )
  end
end
