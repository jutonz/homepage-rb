module Galleries
  module TagSearches
    class FormComponent < ViewComponent::Base
      include Rails.application.routes.url_helpers
      include Turbo::FramesHelper

      erb_template <<~ERB
        <%= turbo_frame_tag("tag-search-form") do %>
          <%= simple_form_for(
            @tag_search,
            url: gallery_image_tag_search_path(@gallery, @image),
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
                    action: "input->auto-submit-form#submit"
                  }
                }
              ) %>
              <%= form.button(:submit, "Search") %>
            </div>
          <% end %>
        <% end %>
      ERB

      def initialize(tag_search:)
        @tag_search = tag_search
        @gallery = tag_search.gallery
        @image = tag_search.image
      end
    end
  end
end
