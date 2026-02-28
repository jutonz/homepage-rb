module Galleries
  class ImageThumbnailComponent < ApplicationComponent
    erb_template <<~ERB
      <%= link_to(
        gallery_image_path(@gallery, @image),
        class: link_classes,
        data: {
          role: "image-thumbnail",
          image_id: @image.id,
          turbo: false,
          gallery_select_target: "image",
          action: "click->gallery-select#toggleImage"
        }
      ) do %>
        <div class="flex justify-center">
          <% if @image.video? %>
            <%= video_tag(@image.file, preload: "metadata") %>
          <% elsif @image.file.variable? %>
            <%= image_tag(@image.file.variant(:thumb)) %>
          <% else %>
            <%= image_tag(@image.file) %>
          <% end %>
        </div>
      <% end %>
    ERB

    def initialize(image:, select_mode: false, selected_ids: [])
      @image = image
      @gallery = image.gallery
      @select_mode = select_mode
      @selected_ids = selected_ids
    end

    private

    def link_classes
      "gallery-image--selected" if @select_mode &&
        @selected_ids.include?(@image.id.to_s)
    end
  end
end
