module Galleries
  class ImageTagsComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers
    include Turbo::FramesHelper

    erb_template <<~ERB
      <%= turbo_frame_tag("image-tags") do %>
        <div class="flex mb-5 flex-col gap-3" data-role="tags">
          <%= render(partial: "galleries/images/tag", collection: @tags) %>
          <span class="hidden only:block">
            This image doesn't have any tags yet.
          </span>
        </div>
      <% end %>
    ERB

    def initialize(image:)
      @tags = image.tags.order(:name)
    end
  end
end
