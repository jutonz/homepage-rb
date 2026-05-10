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
      wait_for_stimulus_controller("refresh-on-visible")
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

      Capybara.using_wait_time(10) do
        expect(page).to have_css(
          "turbo-frame#image-recent-tags",
          text: "new-tag"
        )
      end
      expect(page).to have_css(
        "turbo-frame#image-recent-tags",
        text: "seed-tag"
      )
    end
  end

  def wait_for_stimulus_controller(identifier)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 10
    loop do
      connected = page.evaluate_script(<<~JS)
        (() => {
          const el = document.querySelector(
            "[data-controller~='#{identifier}']"
          )
          if (!el) return false
          const app = window.Stimulus
          if (!app) return false
          return !!app.getControllerForElementAndIdentifier(
            el, "#{identifier}"
          )
        })()
      JS
      break if connected == true
      if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
        raise "Stimulus controller #{identifier} never connected"
      end
      sleep 0.05
    end
  end
end
