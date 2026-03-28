class PillComponent < ApplicationComponent
  COLOR_CLASSES = {
    blue: "bg-blue-100 text-blue-800",
    green: "bg-green-100 text-green-800",
    gray: "bg-gray-100 text-gray-800",
    red: "bg-red-100 text-red-800",
    purple: "bg-purple-100 text-purple-800"
  }.freeze

  renders_many :actions

  erb_template <<~ERB
    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm
                 font-medium <%= @color_classes %> <%= @class_name %>">
      <%= @text %>
      <% actions.each do |action| %>
        <%= action %>
      <% end %>
    </span>
  ERB

  def initialize(text:, color: :blue, class_name: nil)
    @text = text
    @color_classes = color_classes_for(color)
    @class_name = class_name
  end

  private

  def color_classes_for(color)
    COLOR_CLASSES.fetch(color)
  end
end
