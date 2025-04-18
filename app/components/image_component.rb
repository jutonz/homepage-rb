class ImageComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  erb_template <<~ERB
    <%= link_to(
      gallery_image_path(@gallery, @image),
      data: {role: "image", image_id: @image.id, turbo: false}
    ) do %>
      <div class="flex justify-center">
        <% if @image.file.variable? %>
          <%= image_tag(@image.file.variant(:thumb)) %>
        <% else %>
          <%= image_tag(@image.file) %>
        <% end %>
      </div>
    <% end %>
  ERB

  def initialize(image:)
    @image = image
    @gallery = image.gallery
  end
end
