class HeaderComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  erb_template <<~ERB
    <div class="flex w-full mb-8 flex-col">
      <div class="flex space-x-1 w-full mb-3 text-md">
        <% crumbs.each do |crumb| %>
          <%= crumb %>
          <span class="last:hidden">/</span>
        <% end %>
      </div>

      <div class="flex w-full justify-between flex-col sm:flex-row sm:items-center">
        <div class="flex flex-col">
          <h1 class="text-2xl">
            <%= @title %>
          </h1>
        </div>

        <div class="hp-header-actions flex flex-col space-y-2 mt-5 text-center sm:text-left sm:space-y-0 sm:space-x-2 sm:flex-row">
          <% actions.each do |action| %>
            <%= action %>
          <% end %>
        </div>
      </div>
    </div>
  ERB

  renders_many :actions
  renders_many :crumbs, ->(title, path) do
    link_to(title, path)
  end

  def initialize(title:)
    @title = title
  end
end
