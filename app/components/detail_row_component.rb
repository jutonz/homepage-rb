class DetailRowComponent < ApplicationComponent
  erb_template <<~ERB
    <div class="flex justify-between">
      <span class="font-medium text-gray-700"><%= @label %>:</span>
      <span class="<%= @value_class %>"><%= content? ? content : @value %></span>
    </div>
  ERB

  def initialize(label:, value: nil, value_class: nil)
    @label = label
    @value = value
    @value_class = value_class
  end
end
