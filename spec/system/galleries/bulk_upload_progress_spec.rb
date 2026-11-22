require "rails_helper"

RSpec.describe "Gallery bulk upload progress", type: :system do
  def blob_path = "/rails/active_storage/direct_uploads"

  def storage_path = "/rails/active_storage/disk/"

  def bulk_upload_path = %r{/bulk_upload\z}

  def with_images(count, name: nil)
    jpg = Rails.root.join("spec/fixtures/files/audiosurf.jpg")
    Dir.mktmpdir do |root|
      paths = Array.new(count) do |index|
        dir = File.join(root, index.to_s)
        FileUtils.mkdir_p(dir)
        path = File.join(dir, name || "image-#{index}.jpg")
        File.binwrite(path, jpg.binread.ljust(2 * 1024 * 1024, "\0"))
        path
      end
      yield(paths)
    end
  end

  def hold_requests(method, url, limit: nil)
    held = []
    pattern = url.is_a?(Regexp) ? url : %r{#{Regexp.escape(url)}}
    playwright.route(
      pattern,
      lambda { |route, request|
        if request.method == method && (limit.nil? || held.size < limit)
          held << route
        else
          route.fallback
        end
      }
    )
    held
  end

  def wait_until_held(held)
    Timeout.timeout(Capybara.default_max_wait_time) do
      page.evaluate_script("1") while held.empty?
    end
  end

  def prepare(paths)
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)
    visit(new_gallery_bulk_upload_path(gallery))
    attach_file("bulk_upload[files][]", paths, make_visible: true)
    expect(page).to have_css(".dropzone__file-row", count: paths.size)
  end

  def watch_button_text
    page.execute_script(<<~JS)
      window.buttonTexts = []
      const button = document.querySelector(
        "[data-dropzone-target=submitButton]"
      )
      new MutationObserver(() => {
        window.buttonTexts.push(button.value)
      }).observe(button, {attributes: true, attributeFilter: ["value"]})
    JS
  end

  def button_texts = page.evaluate_script("window.buttonTexts")

  def button_text
    page.evaluate_script(
      "document.querySelector(" \
      "'[data-dropzone-target=submitButton]').value"
    )
  end

  def wait_for_button_text(text)
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.05) until button_text == text
    end
  end

  def send_progress(row, percent)
    id = Integer(row["data-upload-id"])
    page.execute_script(<<~JS)
      document.dispatchEvent(new CustomEvent("direct-upload:progress", {
        detail: {id: #{id}, progress: #{percent}}
      }))
    JS
  end

  def bar_style(index)
    row(index).find(".dropzone__progress-bar", visible: :all)[:style]
  end

  def wait_until_held_count(held, count)
    Timeout.timeout(Capybara.default_max_wait_time) do
      page.evaluate_script("1") while held.size < count
    end
  end

  def row(index)
    find(".dropzone__file-row:nth-child(#{index + 1})")
  end

  def status(index) = row(index).find("[data-status]")

  def stats_text(index)
    row(index).find("[data-stats]", visible: :all).text(:all)
  end

  it "queues waiting files, shows each upload's own stats, and " \
    "hands over to the next file", :js do
    with_images(2, name: "same.jpg") do |paths|
      held = hold_requests("PUT", storage_path)
      prepare(paths)

      expect(row(0)).to have_text("2.0 MB")
      expect(page).to have_no_text("Queued")
      expect(page).to have_no_css(".dropzone__progress")
      expect(page).to have_no_css("[data-stats]")

      click_button("Create Bulk upload")

      expect(row(0)).to have_css(".dropzone__progress")
      expect(status(1)).to have_text("Queued", exact: true)
      expect(row(1)).to have_no_css(".dropzone__progress")
      expect(row(1)).to have_no_css("[data-stats]")
      wait_until_held(held)

      send_progress(row(0), 50)

      expect(row(0)).to have_css(
        "[data-stats]", text: /\A1\.0 MB of 2\.0 MB · .+ · ETA: .+\z/
      )
      expect(bar_style(0)).to include("width: 50%")
      expect(row(1)).to have_no_css("[data-stats]")

      sleep(0.6)
      send_progress(row(0), 75)

      expect(row(0)).to have_css(
        "[data-stats]",
        text: %r{\A1\.5 MB of 2\.0 MB · \d+\.\d (KB|MB)/s · ETA: \d+s\z}
      )
      shown = stats_text(0)
      sleep(0.7)
      expect(stats_text(0)).to eq(shown)

      held.first.continue

      expect(status(0)).to have_text("✓")
      expect(row(0)).to have_no_css(".dropzone__progress")
      expect(row(0)).to have_no_css("[data-stats]")
      finished_bar = bar_style(0)
      finished_stats = stats_text(0)
      send_progress(row(0), 10)
      expect(bar_style(0)).to eq(finished_bar)
      expect(stats_text(0)).to eq(finished_stats)
      expect(status(1)).to have_no_text("Queued")
      expect(row(1)).to have_css(".dropzone__progress")
      expect(row(1)).to match_css(".dropzone__file-row--uploading")

      wait_until_held_count(held, 2)
      held.second.fulfill(status: 500, body: "")

      expect(status(1)).to have_text("Failed", exact: true)
      expect(status(0)).to have_text("✓", exact: true)
      expect(row(0)).to match_css(".dropzone__file-row--complete")
    end
  end

  it "starts the clock when the bytes start to go to storage", :js do
    with_images(1) do |paths|
      blob_requests = hold_requests("POST", blob_path)
      hold_requests("PUT", storage_path)
      prepare(paths)
      page.execute_script(<<~JS)
        document.addEventListener(
          "direct-upload:before-storage-request",
          (event) => {
            document.dispatchEvent(new CustomEvent(
              "direct-upload:progress",
              {detail: {id: event.detail.id, progress: 50}}
            ))
          }
        )
      JS

      click_button("Create Bulk upload")
      expect(row(0)).to have_css(".dropzone__progress")
      wait_until_held(blob_requests)
      sleep(0.8)
      blob_requests.first.continue

      expect(row(0)).to have_css(
        "[data-stats]", text: "1.0 MB of 2.0 MB · — · ETA: —"
      )
    end
  end

  it "keeps the bytes of a failed file and its Failed status, " \
    "and never shows Finishing...", :js do
    with_images(1) do |paths|
      held = hold_requests("PUT", storage_path)
      prepare(paths)
      watch_button_text

      click_button("Create Bulk upload")
      expect(row(0)).to have_css(".dropzone__progress")
      wait_until_held(held)
      send_progress(row(0), 50)
      expect(row(0)).to have_css("[data-stats]", text: /\A1\.0 MB of/)
      held.first.fulfill(status: 500, body: "")

      expect(page).to have_button("Create Bulk upload", disabled: false)
      expect(status(0)).to have_text("Failed", exact: true)
      expect(row(0)).to match_css(".dropzone__file-row--error")
      expect(row(0)).to have_no_css(".dropzone__file-row--complete")
      expect(page).to have_no_text("✓")
      expect(stats_text(0)).to match(/\A\d[\d.]* (KB|MB) of 2\.0 MB\z/)
      expect(button_texts).to include("Uploading...")
      expect(button_texts).not_to include("Finishing...")
      failed_text = stats_text(0)
      send_progress(row(0), 90)
      expect(bar_style(0)).to include("width: 50%")
      expect(stats_text(0)).to eq(failed_text)
    end
  end

  it "shows only Failed for a file that failed before any " \
    "bytes, and clears Queued from the files after it", :js do
    with_images(3) do |paths|
      held = hold_requests("POST", blob_path)
      prepare(paths)

      click_button("Create Bulk upload")
      expect(status(1)).to have_text("Queued", exact: true)
      expect(status(2)).to have_text("Queued", exact: true)
      wait_until_held(held)
      held.first.abort

      expect(page).to have_button("Create Bulk upload", disabled: false)
      expect(status(0)).to have_text("Failed", exact: true)
      expect(row(0)).to have_no_css("[data-stats]")
      expect(page).to have_no_text("Queued")
      expect(row(1)).to have_no_css(".dropzone__progress")
      expect(row(2)).to have_no_css(".dropzone__progress")
      expect(page).to have_no_css(".dropzone__file-row--uploading")
    end
  end

  it "shows Finishing... until the redirect, even if the form " \
    "submits again", :js do
    with_images(1) do |paths|
      held = hold_requests("POST", bulk_upload_path)
      prepare(paths)

      click_button("Create Bulk upload")
      wait_until_held(held)
      wait_for_button_text("Finishing...")

      page.execute_script(<<~JS)
        const form = document.querySelector(
          "[data-dropzone-target=submitButton]"
        ).form
        form.addEventListener("submit", (event) => {
          event.preventDefault()
          event.stopPropagation()
        })
        form.dispatchEvent(
          new Event("submit", {bubbles: true, cancelable: true})
        )
      JS

      expect(button_text).to eq("Finishing...")
      expect(page).to have_button(disabled: true)

      held.first.continue

      expect(page).to have_content("Bulk upload successful")
    end
  end

  it "shows no Queued on a retry, and Finishing... when the " \
    "retry's uploads succeed", :js do
    with_images(2) do |paths|
      blob_requests = hold_requests("POST", blob_path, limit: 1)
      bulk_uploads = hold_requests("POST", bulk_upload_path)
      prepare(paths)
      click_button("Create Bulk upload")
      expect(status(1)).to have_text("Queued", exact: true)
      wait_until_held(blob_requests)
      blob_requests.first.abort
      expect(page).to have_button("Create Bulk upload", disabled: false)

      click_button("Create Bulk upload")
      wait_until_held(bulk_uploads)
      wait_for_button_text("Finishing...")

      expect(page).to have_button(disabled: true)
      expect(page).to have_no_text("Queued")
    end
  end

  it "stops reacting to upload events after the controller " \
    "disconnects", :js do
    with_images(1) do |paths|
      prepare(paths)

      js = <<~JS
        const element = document.querySelector("[data-controller~=dropzone]")
        const controller = window.Stimulus.getControllerForElementAndIdentifier(
          element, "dropzone"
        )
        const row = document.querySelector(".dropzone__file-row")
        const button = controller.submitButtonTarget
        const react = () => {
          row.dataset.uploadId = "7"
          row.querySelector("[data-status]").textContent = "Queued"
          controller.uploadStats.clear()
          controller.uploading = true
          button.value = "Uploading..."
          const send = (name, detail) => document.dispatchEvent(
            new CustomEvent(name, {detail})
          )
          send("direct-upload:start", {id: 7})
          send("direct-upload:before-storage-request",
            {id: 7, file: {size: 100}})
          send("direct-uploads:end", {})
          return [
            row.querySelector("[data-status]").textContent,
            controller.uploadStats.size,
            button.value
          ]
        }
        const connected = react()
        controller.disconnect()
        return [connected, react()]
      JS
      connected, disconnected = page.evaluate_script("(() => {#{js}})()")

      expect(connected).to eq(["", 1, "Finishing..."])
      expect(disconnected).to eq(["Queued", 0, "Uploading..."])
    end
  end
end
