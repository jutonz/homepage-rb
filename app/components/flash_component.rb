class FlashComponent < ViewComponent::Base
  erb_template <<~ERB
    <%= tag.div(
      @message,
      class: "border-cyan-100 border-4 rounded px-4 py-3 shadow-md min-w-[300px]",
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
end
