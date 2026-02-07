require "rails_helper"

RSpec.describe Plants::PlantImageComponent, type: :component do
  it "renders the image" do
    plant_image = create(:plants_plant_image)
    component = described_class.new(plant_image: plant_image)
    render_inline(component)

    expect(page).to(have_css("img"))
  end

  it "shows taken_at when present" do
    plant_image = create(:plants_plant_image, :with_taken_at)
    component = described_class.new(plant_image: plant_image)
    render_inline(component)

    expect(page).to(have_content("Taken: 2024-01-02"))
  end
end
