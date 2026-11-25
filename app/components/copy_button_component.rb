# typed: true

class CopyButtonComponent < ApplicationComponent
  RESET_DELAY_MS = 2000

  erb_template <<~ERB
    <%= tag.button(
      "Copy",
      type: "button",
      class: "button button--small button--secondary",
      data: {
        controller: "copy",
        action: "copy#copy",
        copy_value_value: @value,
        copy_delay_value: RESET_DELAY_MS
      }
    ) %>
  ERB

  sig { params(value: String).void }
  def initialize(value:)
    @value = value
  end
end
