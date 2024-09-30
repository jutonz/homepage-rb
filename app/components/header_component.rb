class HeaderComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  erb_template <<~ERB
    <div class="flex w-full justify-between items-center mb-8">
      <h1 class="text-xl">
        <%= @title %>
      </h1>

      <div class="flex">
      <% actions.each do |action| %>
        <%= action %>
      <% end %>
      </div>
    </div>
  ERB

  renders_many :actions

  def initialize(title:)
    @title = title
  end
end
