class SimilarImagesComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  erb_template <<~ERB
    <div data-role="similar-images">
      <h2 class="text-xl mb-4">Similar images</h2>

      <div class="flex gap-3 overflow-x-scroll">
        <% @similar_images.take(5).each do |image| %>
          <div class="min-w-[100px]">
            <%= render(ImageComponent.new(image:)) %>
          </div>
        <% end %>
      </div>
    </div>
  ERB

  def initialize(image:, similar_images:)
    @image = image
    @similar_images = similar_images
  end
end
