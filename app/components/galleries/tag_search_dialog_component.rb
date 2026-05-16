module Galleries
  class TagSearchDialogComponent < ApplicationComponent
    erb_template <<~ERB
      <dialog
        data-controller="tag-search"
        class="m-0 p-0 border-0 bg-white w-screen
          max-w-none h-[100dvh] max-h-[100dvh]
          open:flex flex-col backdrop:bg-black/50"
      >
        <div
          class="flex-none px-4 py-3 border-b
            flex items-center gap-3"
        >
          <h3 class="text-lg grow"><%= @title %></h3>
          <button
            type="button"
            class="button"
            data-action="dialog#close"
          >Done</button>
        </div>

        <div class="flex-1 overflow-y-auto px-4 py-3">
          <%= helpers.simple_form_for(
            @tag_search,
            url: helpers.gallery_tag_search_path(@gallery),
            method: :get,
            html: {
              data: {
                turbo_frame: @turbo_frame,
                controller: "auto-submit-form"
              }
            }
          ) do |form| %>
            <%= helpers.hidden_field_tag(
              "tag_search[mode]", @mode
            ) %>
            <%= helpers.hidden_field_tag(
              "tag_search[turbo_frame_tag]",
              @turbo_frame
            ) %>
            <div class="flex w-full gap-3 mb-4">
              <%= form.input(
                :query,
                label: false,
                wrapper_html: {class: "grow"},
                input_html: {
                  autofocus: true,
                  autocorrect: "off",
                  autocomplete: "off",
                  aria: {label: "Tag search query"},
                  data: {
                    tag_search_target: "query",
                    action: [
                      "input->auto-submit-form#submit",
                      "keydown->tag-search#submitFirstResult"
                    ].join(" ")
                  }
                }
              ) %>
              <%= form.button(:submit, "Search") %>
            </div>
          <% end %>

          <%= selected_tags if selected_tags %>

          <div data-tag-search-target="results">
            <%= helpers.turbo_frame_tag(@turbo_frame) %>
          </div>

          <%= footer if footer %>
        </div>
      </dialog>
    ERB

    renders_one :footer
    renders_one :selected_tags

    def initialize(
      gallery:,
      tag_search:,
      mode:,
      turbo_frame:,
      title: "Search tags"
    )
      @gallery = gallery
      @tag_search = tag_search
      @mode = mode
      @turbo_frame = turbo_frame
      @title = title
    end
  end
end
