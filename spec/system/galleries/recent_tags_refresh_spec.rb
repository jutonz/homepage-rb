require "rails_helper"

RSpec.describe "Recent tags refresh on visibility change", type: :system do
  it "shows tags added in another tab after the tab regains focus", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image_a = create(:galleries_image, gallery:)
    image_b = create(:galleries_image, gallery:)
    seed_tag = create(:galleries_tag, gallery:, name: "seed-tag")
    image_b.add_tag(seed_tag)
    create(:galleries_tag, gallery:, name: "new-tag")

    Capybara.using_session("tab_a") do
      login_as(user)
      visit(gallery_image_path(gallery, image_a))
      expect(page).to have_css(
        "turbo-frame#image-recent-tags",
        text: "seed-tag"
      )
      wait_for_stimulus("refresh-on-visible")
    end

    Capybara.using_session("tab_b") do
      login_as(user)
      visit(gallery_image_path(gallery, image_b))
      fill_in("Tag search query", with: "new-tag")
      find("[data-role=tag-search-result]", text: "new-tag")
        .find_button("Add tag").click
      expect(page).to have_css("[data-role=tag]", text: "new-tag")
    end

    Capybara.using_session("tab_a") do
      expect(page).to have_no_css(
        "turbo-frame#image-recent-tags",
        text: "new-tag"
      )

      page.execute_script(
        "document.dispatchEvent(new Event('visibilitychange'))"
      )

      expect(page).to have_css(
        "turbo-frame#image-recent-tags",
        text: "new-tag",
        wait: 10
      )
      expect(page).to have_css(
        "turbo-frame#image-recent-tags",
        text: "seed-tag"
      )
    end
  end
end
