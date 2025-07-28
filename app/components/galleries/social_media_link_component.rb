module Galleries
  class SocialMediaLinkComponent < ApplicationComponent
    erb_template <<~ERB
      <div data-role="social-link" class="flex justify-between items-center p-3 bg-gray-50 rounded-md">
        <div class="flex items-center">
          <%= link_to(@link.href, class: "flex items-center text-blue-600 hover:text-blue-800 font-medium") do %>
            <% if icon_path %>
              <%= image_tag(icon_path, alt: "\#{@link.platform} icon", class: "h-[20px] w-[20px] mr-2") %>
            <% end %>
            <%= @link.username %>
          <% end %>
        </div>
        <div class="flex items-center">
          <%= link_to(
            "Edit",
            edit_gallery_tag_social_media_link_path(@gallery, @tag, @link),
            class: "button button--small"
          ) %>
        </div>
      </div>
    ERB

    def initialize(link:)
      @link = link
      @tag = link.tag
      @gallery = link.gallery
    end

    private

    def icon_path
      case @link.platform
      when "instagram" then "socials/instagram.png"
      when "reddit" then "socials/reddit.png"
      when "tiktok" then "socials/tiktok.png"
      end
    end
  end
end
