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
end
