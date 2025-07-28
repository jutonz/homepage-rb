class CardComponent < ApplicationComponent
  erb_template <<~ERB
    <div class="bg-white rounded-lg border border-gray-200 p-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-xl font-semibold text-gray-900"><%= @title %></h3>
        <% if actions.any? %>
          <div class="flex space-x-2">
            <% actions.each do |action| %>
              <%= action %>
            <% end %>
          </div>
        <% end %>
      </div>

      <%= content %>
    </div>
  ERB

  renders_many :actions

  def initialize(title:)
    @title = title
  end
end
