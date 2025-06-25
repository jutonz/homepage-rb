module Galleries
  class SimilarImagesComponent < ApplicationComponent
    erb_template <<~ERB
      <div data-role="similar-images">
        <h2 class="text-xl mb-4"><%= @title %></h2>

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

    def initialize(image:, scope:, title: "Similar Images", page: 1)
      @title = title
      @image = image
      @similar_images = scope.page(page).per(PER_PAGE)
    end
  end
end
