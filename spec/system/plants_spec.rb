require "rails_helper"

RSpec.describe "Plant management", type: :system do
  it "creates a plant from the home page" do
    user = create(:user)
    login_as(user)

    visit(home_path)
    click_link("View Plants")

    expect(page).to have_content("No plants yet")

    click_link("New Plant")

    fill_in("Name", with: "Snake Plant")

    click_button("Create Plant")

    expect(page).to have_content("Plant was created.")
    expect(page).to have_content("Snake Plant")
  end

  it "edits a plant from the show page" do
    user = create(:user)
    plant = create(:plant, user:, name: "Old Name")
    login_as(user)
    visit plant_path(plant)

    click_link("Edit")

    fill_in("Name", with: "New Name")
    fill_in("Purchased from", with: "Home Depot")
    fill_in("Purchased at", with: "2024-06-15")
    click_button("Update Plant")

    expect(page).to have_content("Plant was updated.")
    expect(page).to have_content("New Name")
    expect(page).to have_content("Home Depot")
    expect(page).to have_content("2024-06-15")
  end

  it "deletes a plant from the show page" do
    user = create(:user)
    plant = create(:plant, user:)
    login_as(user)
    visit plant_path(plant)

    click_button("Delete")

    expect(page).to have_content("Plant was deleted.")
    expect(page).not_to have_content(plant.name)
  end

  it "adds an image from the show page" do
    user = create(:user)
    plant = create(:plant, user:)
    login_as(user)
    visit plant_path(plant)

    click_link("Add Image")

    attach_file(
      "File",
      Rails.root.join("spec/fixtures/files/audiosurf.jpg")
    )
    fill_in("Taken at", with: "2024-01-02")
    click_button("Add Image")

    expect(page).to have_content("Image was added.")
    expect(page).to have_content("Taken at: 2024-01-02")
    expect(page).to have_css("img")

    plant_image = Plants::PlantImage.order(:id).last
    find(
      "[data-image-id='#{plant_image.id}'] a"
    ).click

    expect(page).to have_content("Taken at: 2024-01-02")
    expect(page).to have_button("Delete")
  end

  it "updates a plant image" do
    user = create(:user)
    plant = create(:plant, user:)
    plant_image = create(:plants_plant_image, plant:)
    login_as(user)
    visit plant_plant_image_path(plant, plant_image)

    click_link("Edit")

    fill_in("Taken at", with: "2024-02-03")
    click_button("Update Image")

    expect(page).to have_content("Image was updated.")
    expect(page).to have_content("Taken at: 2024-02-03")
  end
end
