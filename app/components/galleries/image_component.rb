module Galleries
  class ImageComponent < ApplicationComponent
    erb_template <<~ERB
      <div data-role="image" data-image-id='<%= @image.id %>'>
        <% if @image.video? %>
          <%= video_tag(
            rails_blob_url(@image.file, only_path: true),
            controls: true,
            autoplay: false,
            loop: false,
            preload: "metadata"
          ) %>
        <% else %>
          <%= link_to(rails_blob_url(@image.file, only_path: true)) do %>
            <%= image_tag(@image.file) %>
          <% end %>
        <% end %>
      </div>
    ERB

    def initialize(image:)
      @image = image
    end
  end
end
