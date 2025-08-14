class PillComponent < ApplicationComponent
  COLOR_CLASSES = {
    blue: "bg-blue-100 text-blue-800",
    green: "bg-green-100 text-green-800",
    gray: "bg-gray-100 text-gray-800"
  }.freeze

  erb_template <<~ERB
    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium <%= @color_classes %>">
      <%= @text %>
    </span>
  ERB

  def initialize(text:, color: :blue)
    @text = text
    @color_classes = color_classes_for(color)
  end

  private

  def color_classes_for(color)
    COLOR_CLASSES.fetch(color)
  end
end
