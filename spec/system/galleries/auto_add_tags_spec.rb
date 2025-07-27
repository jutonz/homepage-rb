require "rails_helper"

RSpec.describe "Gallery auto add tags", type: :system do
  it "can add and remove auto-add tags from a tag" do
    user = create(:user)
    gallery = create(:gallery, user:)
    main_tag = create(:galleries_tag, gallery:, name: "main tag")
    auto_tag = create(:galleries_tag, gallery:, name: "auto tag")
    create(:galleries_tag, gallery:, name: "Zebra tag")
    create(:galleries_tag, gallery:, name: "Apple tag")
    login_as(user)

    visit(gallery_tag_path(gallery, main_tag))

    # Add auto-add tag
    within("[data-role=auto-add-tags]") do
      click_on("Add auto-add tag")
    end

    expect(page).to have_current_path(
      new_gallery_tag_auto_add_tag_path(gallery, main_tag)
    )

    # Verify tags are ordered alphabetically
    select_options = page.all('select[name="auto_add_tag[auto_add_tag_id]"] option')
      .map(&:text)
      .reject { |text| text.blank? || text == "Select a tag to auto-add" }
    expect(select_options).to eq(["Apple tag", "auto tag", "Zebra tag"])

    select(auto_tag.name, from: "Auto add tag")
    click_on("Create Auto add tag")

    expect(page).to have_current_path(gallery_tag_path(gallery, main_tag))
    expect(page).to have_content("Auto add tag was successfully created")

    within("[data-role=auto-add-tags]") do
      expect(page).to have_content(auto_tag.name)
      expect(page).to have_link(
        auto_tag.name,
        href: gallery_tag_path(gallery, auto_tag)
      )
    end

    # Remove auto-add tag
    within("[data-role=auto-add-tags]") do
      within("[data-role=auto-add-tag]", text: auto_tag.name) do
        click_on("Remove")
      end
    end

    within("[data-role=auto-add-tags]") do
      expect(page).not_to have_content(auto_tag.name)
    end
  end
end
