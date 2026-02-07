require "rails_helper"

RSpec.describe Plants::PlantImageComponent, type: :component do
  it "renders the image" do
    plant_image = create(:plants_plant_image)
    component = described_class.new(plant_image: plant_image)
    render_inline(component)

    expect(page).to(have_css("img"))
    expect(page).to(have_content(
      "Taken at: #{plant_image.taken_at.to_date.iso8601}"
    ))
  end

  it "links to the plant image" do
    plant_image = create(:plants_plant_image)
    url = Rails.application.routes.url_helpers.plant_plant_image_path(
      plant_image.plant,
      plant_image
    )
    component = described_class.new(plant_image: plant_image)
    render_inline(component)

    expect(page).to(
      have_link(
        nil,
        href: url
      )
    )
  end
end
