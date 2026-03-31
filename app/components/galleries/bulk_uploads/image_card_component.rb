module Galleries
  module BulkUploads
    class ImageCardComponent < ApplicationComponent
      erb_template <<~ERB
        <div id="<%= dom_id(@image, :card) %>">
          <% if @image.processing? %>
            <div data-role="processing-image-card"
                 class="flex items-center justify-center
                        w-full h-32 bg-gray-100 animate-pulse">
              <span class="text-sm text-gray-500">Processing...</span>
            </div>
          <% else %>
            <%= render(Galleries::ImageThumbnailComponent.new(image: @image)) %>
          <% end %>
        </div>
      ERB

      def initialize(image:)
        @image = image
      end
    end
  end
end
