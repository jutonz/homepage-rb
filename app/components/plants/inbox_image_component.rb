module Plants
  class InboxImageComponent < ApplicationComponent
    erb_template <<~ERB
      <div
        class="p-2 bg-white shadow-sm hover:shadow-md transition-shadow"
        data-image-id="<%= @inbox_image.id %>"
      >
        <div class="flex justify-center mb-2">
          <%= image_tag(@inbox_image.file, loading: "lazy") %>
        </div>
        <div class="text-xs text-gray-600 mb-2">
          Taken <%= @inbox_image.taken_at.to_date %>
        </div>
        <% if action.present? %>
          <div class="mt-2">
            <%= action %>
          </div>
        <% end %>
      </div>
    ERB

    renders_one :action

    def initialize(inbox_image:)
      @inbox_image = inbox_image
    end
  end
end
