require "rails_helper"

RSpec.describe "Upload stats module", type: :system do
  def run_in_module(body)
    user = create(:user)
    gallery = create(:gallery, user:)
    login_as(user)
    visit(new_gallery_bulk_upload_path(gallery))

    page.evaluate_async_script(<<~JS)
      const done = arguments[0]
      import("util/upload_stats")
        .then((stats) => {
          const MB = 1024 * 1024
          let t = 0
          const now = () => t
          #{body}
        })
        .catch((error) => done(String(error)))
    JS
  end

  it "formats sizes in base 1024 with one decimal", :js do
    result = run_in_module(<<~JS)
      const KB = 1024
      const GB = 1024 * MB
      done([0, 1023, KB, MB - 1, MB, GB - 1, GB, 1.2 * GB]
        .map((bytes) => stats.formatSize(bytes)))
    JS

    expect(result).to eq(
      [
        "0 B", "1023 B", "1.0 KB", "1024.0 KB",
        "1.0 MB", "1024.0 MB", "1.0 GB", "1.2 GB"
      ]
    )
  end

  it "formats an ETA rounded up to whole seconds", :js do
    result = run_in_module(<<~JS)
      done([0.2, 32, 59, 59.5, 60, 245, 3599, 3600, 3720]
        .map((seconds) => stats.formatEta(seconds)))
    JS

    expect(result).to eq(
      [
        "1s", "32s", "59s", "1m 00s", "1m 00s",
        "4m 05s", "59m 59s", "1h 00m", "1h 02m"
      ]
    )
  end

  it "shows dashes for 0.5 s, then rate and ETA, and holds " \
    "them still while no bytes arrive", :js do
    result = run_in_module(<<~JS)
      const upload = new stats.UploadStats(10 * MB, now)
      t = 499
      upload.record(MB)
      const warmup = upload.summary()
      t = 500
      upload.record(MB)
      const warmed = upload.summary()
      t = 4000
      const stalled = upload.summary()
      t = 4500
      upload.record(10 * MB)
      done([warmup, warmed, stalled, upload.summary()])
    JS

    expect(result).to eq(
      [
        "1.0 MB of 10.0 MB · — · ETA: —",
        "1.0 MB of 10.0 MB · 2.0 MB/s · ETA: 5s",
        "1.0 MB of 10.0 MB · 2.0 MB/s · ETA: 5s",
        "10.0 MB of 10.0 MB · 2.2 MB/s · ETA: 0s"
      ]
    )
  end

  it "uses everything before 5 s and only the last 5 s " \
    "after", :js do
    result = run_in_module(<<~JS)
      const upload = new stats.UploadStats(1000 * MB, now)
      t = 1000
      upload.record(100 * MB)
      const early = upload.summary()
      t = 6000
      upload.record(105 * MB)
      const edge = upload.summary()
      t = 6001
      upload.record(106 * MB)
      done([early, edge, upload.summary()])
    JS

    expect(result).to eq(
      [
        "100.0 MB of 1000.0 MB · 100.0 MB/s · ETA: 9s",
        "105.0 MB of 1000.0 MB · 1.0 MB/s · ETA: 14m 55s",
        "106.0 MB of 1000.0 MB · 1000.0 MB/s · ETA: 1s"
      ]
    )
  end

  it "shows dashes when the two latest figures are more than " \
    "5 s apart, until the next figure", :js do
    result = run_in_module(<<~JS)
      const upload = new stats.UploadStats(100 * MB, now)
      t = 1000
      upload.record(10 * MB)
      t = 7000
      upload.record(20 * MB)
      const gap = upload.summary()
      t = 8000
      upload.record(30 * MB)
      done([gap, upload.summary()])
    JS

    expect(result).to eq(
      [
        "20.0 MB of 100.0 MB · — · ETA: —",
        "30.0 MB of 100.0 MB · 10.0 MB/s · ETA: 7s"
      ]
    )
  end

  it "starts its clock when it is created", :js do
    result = run_in_module(<<~JS)
      t = 10000
      const upload = new stats.UploadStats(10 * MB, now)
      t = 10400
      upload.record(MB)
      const early = upload.summary()
      t = 10500
      upload.record(2 * MB)
      done([early, upload.summary(), upload.bytesText()])
    JS

    expect(result).to eq(
      [
        "1.0 MB of 10.0 MB · — · ETA: —",
        "2.0 MB of 10.0 MB · 4.0 MB/s · ETA: 2s",
        "2.0 MB of 10.0 MB"
      ]
    )
  end

  it "shows dashes when no bytes arrived in the window", :js do
    result = run_in_module(<<~JS)
      const upload = new stats.UploadStats(10 * MB, now)
      t = 1000
      upload.record(MB)
      t = 2000
      upload.record(MB)
      t = 3000
      upload.record(MB)
      t = 6500
      upload.record(MB)
      done(upload.summary())
    JS

    expect(result).to eq("1.0 MB of 10.0 MB · — · ETA: —")
  end

  it "rounds a rate below 1 KB/s to whole bytes", :js do
    result = run_in_module(<<~JS)
      const upload = new stats.UploadStats(10 * 1024, now)
      t = 3000
      upload.record(1024)
      done(upload.summary())
    JS

    expect(result).to eq("1.0 KB of 10.0 KB · 341 B/s · ETA: 27s")
  end
end
