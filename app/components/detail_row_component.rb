# typed: true

class DetailRowComponent < ApplicationComponent
  erb_template <<~ERB
    <div class="flex justify-between">
      <span class="font-medium text-gray-700"><%= @label %>:</span>
      <%= tag.span(content? ? content : @value, class: @value_class) %>
    </div>
  ERB

  def initialize(label:, value: nil, value_class: nil)
    @label = label
    @value = value
    @value_class = value_class
  end
end
