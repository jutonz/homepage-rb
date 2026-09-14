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
            <% @extra_search_params.each do |name, value| %>
              <%= helpers.hidden_field_tag(search_param_name(name), value) %>
            <% end %>
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
          search_path: String,
          # A GET form replaces the query component of its action URL with the
          # form data, and discards the parameters in `search_path`. Put them
          # here.
          extra_search_params: T::Hash[Symbol, T.untyped]
        ).void
      end
      def initialize(tag_search:, search_path:, extra_search_params: {})
        @tag_search = tag_search
        @search_path = search_path
        @extra_search_params = extra_search_params
      end

      private

      sig { params(name: Symbol).returns(String) }
      def search_param_name(name)
        "#{@tag_search.class.model_name.param_key}[#{name}]"
      end
    end
  end
end
