# typed: true

module Galleries
  class RemovableTagPillComponent < ApplicationComponent
    erb_template <<~ERB
      <%= turbo_frame_tag(@frame_id, data: {role: "tag"}) do %>
        <%= render(Galleries::TagPillComponent.new(tag: @tag)) do |c| %>
          <% c.with_action do %>
            <%= link_to(
              "×",
              @remove_path,
              aria: {label: "Remove \#{@tag.name}"},
              data: {
                turbo_method: :delete,
                turbo_confirm: @turbo_confirm
              }.compact,
              class: "opacity-60 hover:opacity-100"
            ) %>
          <% end %>
        <% end %>
      <% end %>
    ERB

    sig do
      params(
        tag: Galleries::Tag,
        frame_id: T.any(String, Galleries::Tag),
        remove_path: String,
        turbo_confirm: T.nilable(String)
      ).void
    end
    def initialize(tag:, frame_id:, remove_path:, turbo_confirm: nil)
      @tag = tag
      @frame_id = frame_id
      @remove_path = remove_path
      @turbo_confirm = turbo_confirm
    end
  end
end
