require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownload do
  it { is_expected.to belong_to(:gallery) }
  it { is_expected.to belong_to(:image).optional }

  it { is_expected.to validate_presence_of(:url) }

  it {
    is_expected.to define_enum_for(:status)
      .with_values(
        pending: "pending",
        downloading: "downloading",
        completed: "completed",
        failed: "failed"
      )
      .backed_by_column_of_type(:enum)
      .with_prefix(:status)
  }

  it "has a valid factory" do
    expect(build(:galleries_remote_video_download)).to be_valid
  end
end
