class HeaderComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  erb_template <<~ERB
    <div class="flex w-full justify-between items-center mb-8">
      <div class="flex flex-col">
        <div class="mb-3 text-md">
          <% crumbs.each do |crumb| %>
            <%= crumb %>
            <span class="last:hidden">/</span>
          <% end %>
        </div>
        <h1 class="text-xl">
          <%= @title %>
        </h1>
      </div>

      <div class="flex">
      <% actions.each do |action| %>
        <%= action %>
      <% end %>
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
