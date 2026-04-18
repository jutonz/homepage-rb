require "rails_helper"

RSpec.describe "Gallery filtering" do
  it "allows filtering and unfiltering by a tag", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    tag = create(:galleries_tag, gallery:)
    image.add_tag(tag)
    login_as(user)

    visit(gallery_path(gallery, image))

    fill_in("Tag search query", with: tag.name)
    click_on("Search")
    within("[data-role=tag-search-result]", text: tag.name) do
      click_on("Add")
    end

    expect(page).not_to have_css(
      "[data-role=tag-search-result]",
      text: tag.name
    )
    expect(page).to have_css("[data-image-id='#{image.id}']")
    expect(page).to have_css(
      "[data-role=tag-filter-remove-button]",
      text: tag.name
    )
    expect(page).to have_field("Tag search query", with: tag.name)
    expect(page).to have_selector(
      "[aria-label='Tag search query']:focus"
    )

    find(
      "[data-role=tag-filter-remove-button]",
      text: tag.name
    ).click
    expect(page).to have_css("[data-image-id='#{image.id}']")
  end

  it "adds a filter when pressing Enter on a search result", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    tag = create(:galleries_tag, gallery:, name: "alpha")
    create(:galleries_tag, gallery:, name: "alpine")
    image.add_tag(tag)
    login_as(user)

    visit(gallery_path(gallery))

    fill_in("Tag search query", with: "alp")
    click_on("Search")
    expect(page).to have_css(
      "[data-role=tag-search-result]",
      text: tag.name
    )

    find_field("Tag search query").send_keys(:enter)

    expect(page).to have_css(
      "[data-role=tag-filter-remove-button]",
      text: tag.name
    )
    expect(page).to have_css("[data-image-id='#{image.id}']")
    expect(page).to have_field("Tag search query", with: "alp")
    expect(page).to have_selector(
      "[aria-label='Tag search query']:focus"
    )
  end

  it "preserves the query when pressing Enter with no results", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)

    visit(gallery_path(gallery))

    fill_in("Tag search query", with: "zzz")
    expect(page).not_to have_css("[data-role=tag-search-result]")

    find_field("Tag search query").send_keys(:enter)

    expect(page).to have_field("Tag search query", with: "zzz")
  end
end
