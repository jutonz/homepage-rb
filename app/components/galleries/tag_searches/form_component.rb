# typed: true

module Galleries
  module TagSearches
    class FormComponent < ApplicationComponent
      erb_template <<~ERB
        <%= turbo_frame_tag("tag-search-form") do %>
          <%= helpers.simple_form_for(
            @tag_search,
            url: @search_path,
            method: :get,
            html: {
              data: {
                turbo_frame: "tag-search-results",
                controller: "auto-submit-form"
              }
            }
          ) do |form| %>
            <div class="flex w-full gap-3">
              <%= form.input(
                :query,
                label: false,
                wrapper_html: {class: "grow"},
                input_html: {
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
        <% end %>
      ERB

      sig do
        params(
          tag_search: Galleries::TagSearch,
          search_path: String
        ).void
      end
      def initialize(tag_search:, search_path:)
        @tag_search = tag_search
        @search_path = search_path
      end
    end
  end
end
