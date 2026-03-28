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
              <%= render(Galleries::TagPillComponent.new(
                tag:,
                link_url: gallery_tag_path(@gallery, tag)
              )) do |c| %>
                <% c.with_action do %>
                  <%= link_to(
                    "×",
                    gallery_image_tag_path(@gallery, @image, tag),
                    data: {
                      turbo_method: :delete,
                      turbo_confirm: "Really remove tag" \
                        " '\#{tag.name}'?"
                    },
                    class: "opacity-60 hover:opacity-100"
                  ) %>
                <% end %>
              <% end %>
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
