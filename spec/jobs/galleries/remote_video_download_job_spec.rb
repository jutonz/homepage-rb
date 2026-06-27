require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownloadJob, "#perform" do
  def stub_metube
    metube = instance_double(Galleries::VideoDownloader::Metube)
    allow(Galleries::VideoDownloader::Metube)
      .to receive(:new).and_return(metube)
    metube
  end

  it "starts the download and transitions to downloading" do
    metube = stub_metube
    allow(metube).to receive(:add)
    rvd = create(:galleries_remote_video_download, status: "pending")

    described_class.new.perform(rvd)

    expect(metube).to have_received(:add)
      .with(url: rvd.url, prefix: "rvd-#{rvd.id}")
    expect(rvd.reload).to be_status_downloading
  end

  it "re-enqueues itself to poll" do
    metube = stub_metube
    allow(metube).to receive(:add)
    rvd = create(:galleries_remote_video_download, status: "pending")

    expect { described_class.new.perform(rvd) }
      .to have_enqueued_job(described_class)
      .with(rvd).on_queue("background")
  end

  it "does nothing when status is not pending or downloading" do
    allow(Galleries::VideoDownloader::Metube).to receive(:new)
    rvd = create(:galleries_remote_video_download, status: "completed")

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
      "filename" => "clip.mp4", "id" => "id-1"
    }
    allow(metube).to receive(:history)
      .and_return("done" => [entry], "queue" => [], "pending" => [])
    allow(metube).to receive(:fetch_file).and_return("videobytes")
    allow(metube).to receive(:delete)

    described_class.new.perform(rvd)

    expect(metube).to have_received(:delete).with("id-1")
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
end
