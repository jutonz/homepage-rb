module Galleries
  class BulkUploadSelectedTagComponent < ApplicationComponent
    erb_template <<~ERB
      <%= turbo_frame_tag(@frame_id, data: {role: "tag"}) do %>
        <%= render(Galleries::TagPillComponent.new(tag: @tag)) do |c| %>
          <% c.with_action do %>
            <%= link_to(
              "×",
              gallery_bulk_upload_tag_path(@tag.gallery, @tag),
              aria: {label: "Remove \#{@tag.name}"},
              data: {turbo_method: :delete},
              class: "opacity-60 hover:opacity-100"
            ) %>
          <% end %>
        <% end %>
      <% end %>
    ERB

    def initialize(tag:, frame_id:)
      @tag = tag
      @frame_id = frame_id
    end
  end
end
