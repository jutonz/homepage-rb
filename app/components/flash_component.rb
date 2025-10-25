class FlashComponent < ApplicationComponent
  erb_template <<~ERB
    <%= tag.div(
      @message,
      class: classes,
      data: {
        role: "flash",
        flash_type: @type
      }
    ) %>
  ERB

  def initialize(message:, type:)
    @message = message
    @type = type
  end

  private

  def classes
    base_classes =
      "border-4 rounded-sm px-4 py-3 shadow-md md:min-w-[300px]"
    "#{base_classes} border-#{color_name}-500 bg-#{color_name}-50"
  end

  def color_name
    case @type.to_sym
    when :success
      "emerald"
    when :error, :alert
      "rose"
    when :warning
      "amber"
    else # :notice and other types
      "sky"
    end
  end
end
