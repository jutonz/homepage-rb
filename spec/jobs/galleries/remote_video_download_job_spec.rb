require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownloadJob, "#perform" do
  include ActiveJob::TestHelper

  it "discards the poll job when the download was deleted" do
    rvd = create(:galleries_remote_video_download, status: "downloading")
    described_class.perform_later(rvd)
    rvd.destroy!

    expect { perform_enqueued_jobs }.not_to raise_error
  end

  def stub_metube
    metube = instance_double(Galleries::VideoDownloader::Metube)
    allow(Galleries::VideoDownloader::Metube)
      .to receive(:new).and_return(metube)
    allow(metube).to receive(:history)
      .and_return("queue" => [], "done" => [], "pending" => [])
    metube
  end

  it "starts the download and transitions to downloading" do
    metube = stub_metube
    allow(metube).to receive(:delete_by_prefix)
    allow(metube).to receive(:add)
    rvd = create(:galleries_remote_video_download, status: "pending")

    described_class.new.perform(rvd)

    expect(metube).to have_received(:add)
      .with(url: rvd.url, prefix: "rvd-#{rvd.id}")
    expect(rvd.reload).to be_status_downloading
  end

  it "re-enqueues itself to poll" do
    metube = stub_metube
    allow(metube).to receive(:delete_by_prefix)
    allow(metube).to receive(:add)
    rvd = create(:galleries_remote_video_download, status: "pending")

    expect { described_class.new.perform(rvd) }
      .to have_enqueued_job(described_class)
      .with(rvd).on_queue("background")
  end

  it "reattaches to an in-progress MeTube download without re-adding" do
    metube = stub_metube
    allow(metube).to receive(:add)
    allow(metube).to receive(:delete_by_prefix)
    rvd = create(:galleries_remote_video_download, status: "pending")
    allow(metube).to receive(:history).and_return(
      "queue" => [{"custom_name_prefix" => "rvd-#{rvd.id}"}],
      "done" => []
    )

    described_class.new.perform(rvd)

    expect(metube).not_to have_received(:add)
    expect(metube).not_to have_received(:delete_by_prefix)
    expect(rvd.reload).to be_status_downloading
  end

  it "re-enqueues itself to poll after reattaching" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "pending")
    allow(metube).to receive(:history).and_return(
      "queue" => [{"custom_name_prefix" => "rvd-#{rvd.id}"}],
      "done" => []
    )

    expect { described_class.new.perform(rvd) }
      .to have_enqueued_job(described_class).with(rvd)
  end

  it "reattaches when MeTube already finished the download" do
    metube = stub_metube
    allow(metube).to receive(:add)
    allow(metube).to receive(:delete_by_prefix)
    rvd = create(:galleries_remote_video_download, status: "pending")
    allow(metube).to receive(:history).and_return(
      "queue" => [],
      "done" => [
        {"custom_name_prefix" => "rvd-#{rvd.id}", "status" => "finished"}
      ]
    )

    described_class.new.perform(rvd)

    expect(metube).not_to have_received(:add)
    expect(metube).not_to have_received(:delete_by_prefix)
    expect(rvd.reload).to be_status_downloading
  end

  it "deletes and re-adds when MeTube reports the entry errored" do
    metube = stub_metube
    allow(metube).to receive(:add)
    allow(metube).to receive(:delete_by_prefix)
    rvd = create(:galleries_remote_video_download, status: "pending")
    allow(metube).to receive(:history).and_return(
      "queue" => [],
      "done" => [
        {"custom_name_prefix" => "rvd-#{rvd.id}", "status" => "error"}
      ]
    )

    described_class.new.perform(rvd)

    expect(metube).to have_received(:delete_by_prefix).with("rvd-#{rvd.id}")
    expect(metube).to have_received(:add)
    expect(rvd.reload).to be_status_downloading
  end

  it "does nothing when status is not pending or downloading" do
    allow(Galleries::VideoDownloader::Metube).to receive(:new)
    rvd =
      build_stubbed(:galleries_remote_video_download, status: "completed")

    described_class.new.perform(rvd)

    expect(Galleries::VideoDownloader::Metube)
      .not_to have_received(:new)
  end

  it "downloads, creates a tagged image, and completes" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    entry = {
      "custom_name_prefix" => "rvd-#{rvd.id}",
      "status" => "finished",
      "filename" => "rvd-#{rvd.id} clip.mp4",
      "id" => "rvd-#{rvd.id}.abc"
    }
    allow(metube).to receive(:history)
      .and_return("done" => [entry], "queue" => [], "pending" => [])
    allow(metube).to receive(:fetch_file)
      .with("rvd-#{rvd.id} clip.mp4").and_return("videobytes")
    allow(metube).to receive(:delete)

    described_class.new.perform(rvd)

    rvd.reload
    expect(rvd).to be_status_completed
    expect(rvd.image.file).to be_attached
    expect(rvd.image.tags.map(&:name)).to include("tagging needed")
  end

  it "enqueues image processing for the new image" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    entry = {
      "custom_name_prefix" => "rvd-#{rvd.id}",
      "status" => "finished",
      "filename" => "clip.mp4", "id" => "id-1"
    }
    allow(metube).to receive(:history)
      .and_return("done" => [entry], "queue" => [], "pending" => [])
    allow(metube).to receive(:fetch_file).and_return("videobytes")
    allow(metube).to receive(:delete)

    expect { described_class.new.perform(rvd) }
      .to have_enqueued_job(Galleries::ImageProcessingJob)
  end

  it "deletes the MeTube entry only after the image is saved" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    entry = {
      "custom_name_prefix" => "rvd-#{rvd.id}",
      "status" => "finished",
      "filename" => "clip.mp4", "url" => "https://x/v"
    }
    allow(metube).to receive(:history)
      .and_return("done" => [entry], "queue" => [], "pending" => [])
    allow(metube).to receive(:fetch_file).and_return("videobytes")
    allow(metube).to receive(:delete)

    described_class.new.perform(rvd)

    expect(metube).to have_received(:delete).with("https://x/v")
  end

  it "completes even if cleanup delete fails" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    entry = {
      "custom_name_prefix" => "rvd-#{rvd.id}",
      "status" => "finished",
      "filename" => "clip.mp4", "id" => "id-1"
    }
    allow(metube).to receive(:history)
      .and_return("done" => [entry], "queue" => [], "pending" => [])
    allow(metube).to receive(:fetch_file).and_return("videobytes")
    allow(metube).to receive(:delete)
      .and_raise(Faraday::ConnectionFailed.new("boom"))

    described_class.new.perform(rvd)

    expect(rvd.reload).to be_status_completed
  end

  it "fails with the error message on a MeTube error entry" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    entry = {
      "custom_name_prefix" => "rvd-#{rvd.id}",
      "status" => "error", "error" => "bad video", "msg" => "x"
    }
    allow(metube).to receive(:history)
      .and_return("done" => [entry], "queue" => [], "pending" => [])

    described_class.new.perform(rvd)

    rvd.reload
    expect(rvd).to be_status_failed
    expect(rvd.error_message).to eq("bad video")
  end

  it "re-enqueues while still downloading" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    allow(metube).to receive(:history)
      .and_return("done" => [], "queue" => [], "pending" => [])

    expect { described_class.new.perform(rvd) }
      .to have_enqueued_job(described_class).with(rvd)
    expect(rvd.reload).to be_status_downloading
  end

  it "fails when the overall timeout is exceeded" do
    metube = stub_metube
    rvd = create(
      :galleries_remote_video_download,
      status: "downloading", created_at: 2.hours.ago
    )
    allow(metube).to receive(:history)
      .and_return("done" => [], "queue" => [], "pending" => [])

    described_class.new.perform(rvd)

    rvd.reload
    expect(rvd).to be_status_failed
    expect(rvd.error_message).to match(/timed out/)
  end

  it "fails fast if add is unreachable" do
    metube = stub_metube
    allow(metube).to receive(:delete_by_prefix)
    rvd = create(:galleries_remote_video_download, status: "pending")
    allow(metube).to receive(:add)
      .and_raise(Faraday::ConnectionFailed.new("down"))

    described_class.new.perform(rvd)

    rvd.reload
    expect(rvd).to be_status_failed
    expect(rvd.error_message).to eq("down")
  end

  it "fails without downloading when MeTube rejects the add" do
    metube = stub_metube
    allow(metube).to receive(:delete_by_prefix)
    rvd = create(:galleries_remote_video_download, status: "pending")
    allow(metube).to receive(:add)
      .and_raise(Galleries::VideoDownloader::Metube::Error.new("nope"))

    described_class.new.perform(rvd)

    rvd.reload
    expect(rvd).to be_status_failed
    expect(rvd).not_to be_status_downloading
    expect(rvd.error_message).to eq("nope")
  end

  it "clears any stale MeTube entry before re-adding" do
    metube = stub_metube
    allow(metube).to receive(:delete_by_prefix)
    allow(metube).to receive(:add)
    rvd = create(:galleries_remote_video_download, status: "pending")

    described_class.new.perform(rvd)

    expect(metube).to have_received(:delete_by_prefix)
      .with("rvd-#{rvd.id}")
  end

  it "broadcasts the row when the download starts" do
    metube = stub_metube
    allow(metube).to receive(:delete_by_prefix)
    allow(metube).to receive(:add)
    rvd = create(:galleries_remote_video_download, status: "pending")
    allow(rvd).to receive(:broadcast_row)

    described_class.new.perform(rvd)

    expect(rvd).to have_received(:broadcast_row)
  end

  it "broadcasts the row when the download completes" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    entry = {
      "custom_name_prefix" => "rvd-#{rvd.id}",
      "status" => "finished", "filename" => "clip.mp4", "id" => "id-1"
    }
    allow(metube).to receive(:history)
      .and_return("done" => [entry], "queue" => [], "pending" => [])
    allow(metube).to receive(:fetch_file).and_return("videobytes")
    allow(metube).to receive(:delete)
    allow(rvd).to receive(:broadcast_row)

    described_class.new.perform(rvd)

    expect(rvd).to have_received(:broadcast_row)
  end

  it "broadcasts the row when the download fails" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    allow(metube).to receive(:history)
      .and_raise(Faraday::ConnectionFailed.new("down"))
    allow(rvd).to receive(:broadcast_row)

    described_class.new.perform(rvd)

    expect(rvd).to have_received(:broadcast_row)
  end

  it "fails fast if history is unreachable" do
    metube = stub_metube
    rvd = create(:galleries_remote_video_download, status: "downloading")
    allow(metube).to receive(:history)
      .and_raise(Faraday::ConnectionFailed.new("down"))

    described_class.new.perform(rvd)

    expect(rvd.reload).to be_status_failed
  end
end
