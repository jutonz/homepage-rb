module Galleries
  class SimilarImagesComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers

    erb_template <<~ERB
      <div data-role="similar-images">
        <h2 class="text-xl mb-4">Similar images</h2>

        <div class="flex gap-3 overflow-x-auto">
          <div class="flex items-center px-4">
            <%= link_to_prev_page(
              @similar_images,
              "Previous",
              param_name: :similar_images_page,
            ) %>
          </div>

          <% @similar_images.each do |image| %>
            <div class="min-w-[100px]">
              <%= render(Galleries::ImageThumbnailComponent.new(image:)) %>
            </div>
          <% end %>

          <div class="flex items-center px-4">
            <%= link_to_next_page(
              @similar_images,
              "Next",
              param_name: :similar_images_page,
            ) %>
          </div>
        </div>
      </div>
    ERB

    PER_PAGE = 20

    def initialize(image:, page: 1)
      @image = image
      @similar_images = @image.similar_images.page(page).per(PER_PAGE)
    end
  end
end
