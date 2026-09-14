require "rails_helper"

RSpec.describe "Gallery auto add tags", type: :system, js: true do
  it "can add and remove auto-add tags from a tag" do
    user = create(:user)
    gallery = create(:gallery, user:)
    main_tag = create(:galleries_tag, gallery:, name: "main tag")
    auto_tag = create(:galleries_tag, gallery:, name: "Auto tag")
    login_as(user)

    visit(gallery_tag_path(gallery, main_tag))

    within("[data-role=auto-add-tags]") do
      click_on("Add auto-add tag")
    end

    expect(page).to have_current_path(
      new_gallery_tag_auto_add_tag_path(gallery, main_tag)
    )

    fill_in("Tag search query", with: "Aut")
    find("[data-role=tag-search-result]", text: auto_tag.display_name)
      .click_on("Add")

    expect(page).to have_current_path(gallery_tag_path(gallery, main_tag))
    expect(page).to have_content("Auto add tag was successfully created")

    within("[data-role=auto-add-tags]") do
      expect(page).to have_content(auto_tag.name)
      expect(page).to have_link(
        auto_tag.name,
        href: gallery_tag_path(gallery, auto_tag)
      )
    end

    within("[data-role=auto-add-tags]") do
      within("[data-role=auto-add-tag]", text: auto_tag.name) do
        accept_confirm { click_on("Remove") }
      end
    end

    within("[data-role=auto-add-tags]") do
      expect(page).not_to have_content(auto_tag.name)
    end
  end

  it "adds the first matching tag when Enter is pressed" do
    user = create(:user)
    gallery = create(:gallery, user:)
    main_tag = create(:galleries_tag, gallery:, name: "main tag")
    first_tag = create(:galleries_tag, gallery:, name: "Autumn tag")
    create(:galleries_tag, gallery:, name: "Auto tag")
    login_as(user)

    visit(new_gallery_tag_auto_add_tag_path(gallery, main_tag))

    fill_in("Tag search query", with: "Aut")
    find("[data-role=tag-search-result]", text: first_tag.display_name)
    find_field("Tag search query").send_keys(:enter)

    expect(page).to have_current_path(gallery_tag_path(gallery, main_tag))
    expect(page).to have_content("Auto add tag was successfully created")
    expect(page).to have_content(first_tag.name)
  end

  it "does not search until the query reaches three characters" do
    user = create(:user)
    gallery = create(:gallery, user:)
    main_tag = create(:galleries_tag, gallery:, name: "main tag")
    create(:galleries_tag, gallery:, name: "Auto tag")
    requests = 0
    login_as(user)
    visit(new_gallery_tag_auto_add_tag_path(gallery, main_tag))
    search_path = gallery_tag_search_path(gallery)
    playwright.on(
      "request",
      ->(request) { requests += 1 if URI(request.url).path == search_path }
    )

    fill_in("Tag search query", with: "Au")
    playwright.wait_for_timeout(100)

    expect(requests).to eql(0)
  end

  it "leaves the query intact when Enter has no result to submit" do
    user = create(:user)
    gallery = create(:gallery, user:)
    main_tag = create(:galleries_tag, gallery:, name: "main tag")
    login_as(user)

    visit(new_gallery_tag_auto_add_tag_path(gallery, main_tag))
    fill_in("Tag search query", with: "zzzqqq")
    find_field("Tag search query").send_keys(:enter)

    expect(page).to have_current_path(
      new_gallery_tag_auto_add_tag_path(gallery, main_tag)
    )
    expect(page).to have_field("Tag search query", with: "zzzqqq")
    expect(page).to have_no_css("[data-role=tag-search-result]")
    expect(main_tag.reload.auto_add_tags).to be_empty
  end
end
