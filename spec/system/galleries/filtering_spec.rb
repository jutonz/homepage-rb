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
      "[aria-label='Remove #{tag.name} filter']"
    )
    expect(page).to have_field("Tag search query", with: tag.name)
    expect(page).to have_selector(
      "[aria-label='Tag search query']:focus"
    )

    find("[aria-label='Remove #{tag.name} filter']").click
    expect(page).to have_css("[data-image-id='#{image.id}']")
  end

  it "searches on its own once the viewer stops typing", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:)
    searches = []
    login_as(user)
    visit(gallery_path(gallery))
    playwright.on(
      "request",
      ->(request) {
        searches << request.url if request.url.include?("tag_search")
      }
    )

    fill_in("Tag search query", with: tag.name)
    playwright.wait_for_timeout(500)

    expect(searches).not_to be_empty
    expect(page).to have_css(
      "[data-role=tag-search-result]",
      text: tag.name
    )
  end

  it "runs no further search once the viewer submits one", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    tag = create(:galleries_tag, gallery:)
    searches = []
    login_as(user)
    visit(gallery_path(gallery))
    playwright.on(
      "request",
      ->(request) {
        searches << request.url if request.url.include?("tag_search")
      }
    )

    fill_in("Tag search query", with: tag.name)
    click_on("Search")
    expect(page).to have_css(
      "[data-role=tag-search-result]",
      text: tag.name
    )
    playwright.wait_for_timeout(500)

    expect(searches.last).to include("commit=Search")
  end
end
