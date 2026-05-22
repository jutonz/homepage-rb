module Galleries
  class ImageTagsComponent < ApplicationComponent
    erb_template <<~ERB
      <%= turbo_frame_tag("image-tags") do %>
        <div class="flex mb-5 flex-wrap gap-2" data-role="tags">
          <span class="hidden only:block">
            This image doesn't have any tags yet.
          </span>
          <% @tags.each do |tag| %>
            <%= render(Galleries::RemovableTagPillComponent.new(
              tag:,
              frame_id: tag,
              remove_path:
                gallery_image_tag_path(@gallery, @image, tag),
              turbo_confirm:
                "Really remove tag '\#{tag.name}'?"
            )) %>
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
