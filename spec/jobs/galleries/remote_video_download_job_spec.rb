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
end
