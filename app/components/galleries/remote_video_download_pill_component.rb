module Galleries
  class RemoteVideoDownloadPillComponent < ApplicationComponent
    STATUS_COLORS = {
      "pending" => :gray,
      "downloading" => :blue,
      "completed" => :green,
      "failed" => :red
    }.freeze

    erb_template <<~ERB
      <%= render(PillComponent.new(
        text: @remote_video_download.status,
        color: STATUS_COLORS.fetch(@remote_video_download.status, :gray)
      )) %>
    ERB

    def initialize(remote_video_download:)
      @remote_video_download = remote_video_download
    end
  end
end
