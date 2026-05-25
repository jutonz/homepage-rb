require "rails_helper"

RSpec.describe "Gallery image tags", type: :system do
  it "can add and remove a tag from an image", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    click_on("Search")
    within("[data-role=tag-search-result]", text: tag.name) do
      click_on("Add tag")
    end
    expect(page).not_to have_css(
      "[data-role=tag-search-result]",
      text: tag.name
    )

    within("turbo-frame#tag_#{tag.id}", text: tag.name) do
      expect(image.reload.tags).to include(tag)
      accept_confirm("Really remove tag '#{tag.name}'?") do
        click_on("×")
      end
    end

    expect(page).not_to have_css("turbo-frame#tag_#{tag.id}")
    expect(image.reload.tags).to be_empty
  end

  it "can add and remove a tag from an image with the × button", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    click_on("Search")
    within("[data-role=tag-search-result]", text: tag.name) do
      click_on("Add tag")
    end
    expect(page).to have_css("[data-role=tag]", text: tag.name)

    accept_confirm("Really remove tag '#{tag.name}'?") do
      within("[data-role=tag]", text: tag.name) { click_on("×") }
    end

    expect(page).not_to have_css("turbo-frame#tag_#{tag.id}")
    expect(image.reload.tags).to be_empty
  end

  it "clears the search input when adding a tag", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag1 = create(:galleries_tag, gallery:, name: "testing 1")
    tag2 = create(:galleries_tag, gallery:, name: "testing 2")
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "te")
    click_on("Search")

    result = find("[data-role=tag-search-result]", text: tag1.name)
    result.find_button("Add tag").click
    expect(page).to have_field("Tag search query", with: "")

    expect(page).to have_css(
      "[data-role=tag-search-result]",
      text: tag2.name
    )
  end

  it "automatically submits search form", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:, name: "tagging")
    login_as(user)

    visit(gallery_image_path(gallery, image))

    # does not auto submit short query
    fill_in("Tag search query", with: "ta")
    expect(page).not_to have_css("[data-role=tag-search-result]", text: tag.name)

    # auto submits after 2 characters
    fill_in("Tag search query", with: "tag")
    expect(page).to have_css("[data-role=tag-search-result]", text: tag.name)
  end

  it "adds first result when pressing Enter", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:, name: "alpha")
    create(:galleries_tag, gallery:, name: "alpine")
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "alp")
    click_on("Search")
    expect(page).to have_css(
      "[data-role=tag-search-result]",
      text: tag.name
    )

    find_field("Tag search query").send_keys(:enter)

    expect(page).to have_css(
      "[data-role=tag]",
      text: tag.name
    )
    expect(image.reload.tags).to include(tag)
    expect(page).to have_field(
      "Tag search query",
      with: ""
    )
  end

  it "preserves query when pressing Enter with no results",
    :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "zzz")
    click_on("Search")
    expect(page).not_to have_css(
      "[data-role=tag-search-result]"
    )

    find_field("Tag search query").send_keys(:enter)

    expect(page).to have_field(
      "Tag search query",
      with: "zzz"
    )
  end

  it "navigates to the tag page when clicking the tag pill link", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, :with_real_file, gallery:)
    tag = create(:galleries_tag, gallery:)
    image.add_tag(tag)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    within("[data-role=tag]", text: tag.name) do
      click_on(tag.reload.display_name)
    end

    expect(current_path).to eq(gallery_tag_path(gallery, tag))
  end

  it "allows you to visit a tag by clicking on its search result", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: tag.name[0, 2])
    click_on("Search")

    result = find("[data-role=tag-search-result]", text: tag.name)
    result.find_link(tag.display_name).click
    expect(current_path).to eql(gallery_tag_path(gallery, tag))
  end

  it "refreshes recent tags on visibilitychange", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image_a, image_b = create_pair(:galleries_image, gallery:)
    login_as(user)
    visit(gallery_image_path(gallery, image_a))
    wait_for_stimulus("refresh-on-visible")
    expect(page).to have_css("h4", text: "Recently used tags")

    seed_tag = create(:galleries_tag, gallery:, name: "seed-tag")
    image_b.add_tag(seed_tag)

    page.execute_script(
      "document.dispatchEvent(new Event('visibilitychange'))"
    )
    expect(page).to have_css("[data-role=recent-tag]", text: "seed-tag")
  end

  it "suggests related tags when adding a tag", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    source = create(:galleries_tag, gallery:, name: "source")
    partner = create(:galleries_tag, gallery:, name: "partner")
    create(:galleries_image, gallery:).add_tag(source, partner)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "source")
    expect(page).to have_css("[data-role=tag-search-result]", text: "source")
    within("[data-role=tag-search-result]", text: "source") do
      click_on("Add tag")
    end

    within("[data-role=related-tags-box]") do
      expect(page).to have_text("Related to \"source\"")
      expect(page).to have_text("partner")
      expect(page).to have_text("1 shared")
    end
    expect(image.reload.tags.map(&:name)).to include("source")
  end

  it "adds a related tag from the box and removes its row", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    source = create(:galleries_tag, gallery:, name: "source")
    partner = create(:galleries_tag, gallery:, name: "partner")
    create(:galleries_image, gallery:).add_tag(source, partner)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "source")
    expect(page).to have_css("[data-role=tag-search-result]", text: "source")
    within("[data-role=tag-search-result]", text: "source") do
      click_on("Add tag")
    end

    within("#related-suggestion-#{partner.id}") { click_on("Add tag") }

    expect(page).to have_css("[data-role=tag]", text: "partner")
    expect(page).not_to have_css("#related-suggestion-#{partner.id}")
    expect(image.reload.tags.map(&:name)).to include("partner")
  end

  it "dismisses the related-tags box with the ✕ button", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    source = create(:galleries_tag, gallery:, name: "source")
    partner = create(:galleries_tag, gallery:, name: "partner")
    create(:galleries_image, gallery:).add_tag(source, partner)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "source")
    expect(page).to have_css("[data-role=tag-search-result]", text: "source")
    within("[data-role=tag-search-result]", text: "source") do
      click_on("Add tag")
    end
    expect(page).to have_css("[data-role=related-tags-box]")

    find("[aria-label='Dismiss related tags']").click

    expect(page).not_to have_css("[data-role=related-tags-box]")
  end

  it "shows only the most recent box when adding two tags", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    one = create(:galleries_tag, gallery:, name: "shared one")
    one_partner = create(:galleries_tag, gallery:, name: "one partner")
    two = create(:galleries_tag, gallery:, name: "shared two")
    two_partner = create(:galleries_tag, gallery:, name: "two partner")
    create(:galleries_image, gallery:).add_tag(one, one_partner)
    create(:galleries_image, gallery:).add_tag(two, two_partner)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "shared")
    expect(page).to have_css(
      "[data-role=tag-search-result]",
      text: "shared one"
    )
    within("[data-role=tag-search-result]", text: "shared one") do
      click_on("Add tag")
    end
    expect(page).to have_text("Related to \"shared one\"")

    within("[data-role=tag-search-result]", text: "shared two") do
      click_on("Add tag")
    end

    expect(page).to have_text("Related to \"shared two\"")
    expect(page).not_to have_text("Related to \"shared one\"")
    expect(page).to have_css("[data-role=related-tags-box]", count: 1)
  end

  it "clears the box when starting a new search", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    source = create(:galleries_tag, gallery:, name: "source")
    partner = create(:galleries_tag, gallery:, name: "partner")
    create(:galleries_image, gallery:).add_tag(source, partner)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "source")
    expect(page).to have_css("[data-role=tag-search-result]", text: "source")
    within("[data-role=tag-search-result]", text: "source") do
      click_on("Add tag")
    end
    expect(page).to have_css("[data-role=related-tags-box]")

    fill_in("Tag search query", with: "partner")

    expect(page).not_to have_css("[data-role=related-tags-box]")
  end
end
