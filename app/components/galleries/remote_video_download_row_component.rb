module Galleries
  class RemoteVideoDownloadRowComponent < ApplicationComponent
    erb_template <<~ERB
      <div
        id="remote_video_download_<%= @remote_video_download.id %>"
        class="flex gap-4 py-3"
        data-role="rvd-row"
      >
        <div class="w-[200px] shrink-0">
          <% if completed_with_image? %>
            <%= render(Galleries::ImageThumbnailComponent.new(
              image: @remote_video_download.image
            )) %>
          <% else %>
            <div
              class="flex items-center justify-center w-full
                     h-[120px] bg-gray-100 rounded text-gray-400
                     text-sm"
              data-role="thumbnail-placeholder"
            >
              No video
            </div>
          <% end %>
        </div>

        <div class="flex flex-col items-start gap-1 min-w-0">
          <%= link_to(
            @remote_video_download.url,
            @remote_video_download.url,
            target: "_blank",
            rel: "noopener",
            class: "break-all text-blue-600 hover:text-blue-800"
          ) %>
          <%= render(Galleries::RemoteVideoDownloadPillComponent.new(
            remote_video_download: @remote_video_download
          )) %>
          <% if failed_with_message? %>
            <p class="text-red-600 text-sm" data-role="error-message">
              <%= @remote_video_download.error_message %>
            </p>
          <% end %>
          <% if failed? %>
            <%= button_to(
              "Retry",
              gallery_remote_video_download_retries_path(
                @remote_video_download.gallery,
                @remote_video_download
              ),
              class: "button"
            ) %>
          <% end %>
        </div>
      </div>
    ERB

    def initialize(remote_video_download:)
      @remote_video_download = remote_video_download
    end

    private

    def completed_with_image?
      @remote_video_download.status_completed? &&
        @remote_video_download.image.present?
    end

    def failed_with_message?
      failed? && @remote_video_download.error_message.present?
    end

    def failed?
      @remote_video_download.status_failed?
    end
  end
end
