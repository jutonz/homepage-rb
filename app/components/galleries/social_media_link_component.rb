module Galleries
  class SocialMediaLinkComponent < ApplicationComponent
    erb_template <<~ERB
      <div data-role="social-link" class="flex gap-4 mb-4">
        <%= link_to(@link.href, class:"flex p-2 border-2 border-black rounded-sm border-slate-300") do %>
          <% if icon_path %>
            <%= image_tag(icon_path, alt: "\#{@link.platform} icon", class: "h-[30px] w-[30px] mr-3") %>
          <% end %>
          <div class="flex items-center">
            <%= @link.username %>
          </div>
        <% end %>
        <div class="flex items-center gap-4">
          <%= link_to(
            "Edit",
            edit_gallery_tag_social_media_link_path(@gallery, @tag, @link)
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
