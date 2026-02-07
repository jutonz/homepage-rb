require "rails_helper"

RSpec.describe "Plant management", type: :system do
  it "creates a plant from the home page" do
    user = create(:user)
    login_as(user)

    visit home_path
    click_link "View Plants"

    expect(page).to have_content("No plants yet")

    click_link "New Plant"

    fill_in "Name", with: "Snake Plant"

    click_button "Create Plant"

    expect(page).to have_content("Plant was created.")
    expect(page).to have_content("Snake Plant")
  end
end
