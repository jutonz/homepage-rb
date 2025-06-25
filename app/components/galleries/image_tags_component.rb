module Galleries
  class ImageTagsComponent < ApplicationComponent
    erb_template <<~ERB
      <%= turbo_frame_tag("image-tags") do %>
        <div class="flex mb-5 flex-col gap-3" data-role="tags">
          <span class="hidden only:block">
            This image doesn't have any tags yet.
          </span>
          <% @tags.each do |tag| %>
            <%= turbo_frame_tag(tag, data: {role: "tag"}) do %>
              <div class="flex gap-3 items-center">
                <div>
                  <%= link_to(
                    tag.display_name,
                    gallery_tag_path(@gallery, tag),
                    data: {
                      turbo: false,
                      role: "tag-link"
                    }
                  ) %>
                </div>
                <%= button_to(
                  "Remove",
                  gallery_image_tag_path(@gallery, @image, tag),
                  method: :delete,
                  class: "button button--danger",
                  data: {turbo_confirm: "Are you sure?"}
                ) %>
              </div>
            <% end %>
          <% end %>
        </div>
      <% end %>
    ERB

    def initialize(image:)
      @image = image
      @gallery = image.gallery
      @tags = image.tags.order(:name)
    end
  end
end
