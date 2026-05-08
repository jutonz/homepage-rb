require "rails_helper"

RSpec.describe Galleries::TagSearchDialogComponent,
  type: :component do
  it "renders a dialog with the default title" do
    gallery = build_stubbed(:gallery)
    tag_search = Galleries::TagSearch.new(gallery:)

    render_inline(
      described_class.new(
        gallery:,
        tag_search:,
        mode: "bulk_upload_tag",
        turbo_frame: "bulk-upload-tag-search-results"
      )
    )

    expect(page).to have_css("dialog")
    expect(page).to have_css("h3", text: "Search tags")
  end

  it "renders a custom title" do
    gallery = build_stubbed(:gallery)
    tag_search = Galleries::TagSearch.new(gallery:)

    render_inline(
      described_class.new(
        gallery:,
        tag_search:,
        mode: "bulk_add_tag",
        turbo_frame: "bulk-tag-search-results",
        title: "Add tag to selected images"
      )
    )

    expect(page).to have_css(
      "h3", text: "Add tag to selected images"
    )
  end

  it "renders the search form with hidden mode and frame" do
    gallery = build_stubbed(:gallery)
    tag_search = Galleries::TagSearch.new(gallery:)

    render_inline(
      described_class.new(
        gallery:,
        tag_search:,
        mode: "bulk_upload_tag",
        turbo_frame: "bulk-upload-tag-search-results"
      )
    )

    expect(page).to have_css(
      "input[name='tag_search[mode]']" \
      "[value='bulk_upload_tag']",
      visible: false
    )
    expect(page).to have_css(
      "input[name='tag_search[turbo_frame_tag]']" \
      "[value='bulk-upload-tag-search-results']",
      visible: false
    )
  end

  it "renders the results turbo frame with the given id" do
    gallery = build_stubbed(:gallery)
    tag_search = Galleries::TagSearch.new(gallery:)

    render_inline(
      described_class.new(
        gallery:,
        tag_search:,
        mode: "bulk_upload_tag",
        turbo_frame: "bulk-upload-tag-search-results"
      )
    )

    expect(page).to have_css(
      "turbo-frame#bulk-upload-tag-search-results"
    )
  end

  it "renders the selected_tags slot when provided" do
    gallery = build_stubbed(:gallery)
    tag_search = Galleries::TagSearch.new(gallery:)

    render_inline(
      described_class.new(
        gallery:,
        tag_search:,
        mode: "bulk_upload_tag",
        turbo_frame: "bulk-upload-tag-search-results"
      )
    ) do |c|
      c.with_selected_tags do
        '<div id="my-selected">selected stuff</div>'.html_safe
      end
    end

    expect(page).to have_css("#my-selected")
  end

  it "renders the footer slot when provided" do
    gallery = build_stubbed(:gallery)
    tag_search = Galleries::TagSearch.new(gallery:)

    render_inline(
      described_class.new(
        gallery:,
        tag_search:,
        mode: "bulk_add_tag",
        turbo_frame: "bulk-tag-search-results"
      )
    ) do |c|
      c.with_footer do
        '<div id="my-footer">footer stuff</div>'.html_safe
      end
    end

    expect(page).to have_css("#my-footer")
  end
end
