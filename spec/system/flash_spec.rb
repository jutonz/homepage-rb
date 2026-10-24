require "rails_helper"

RSpec.describe "Flash", type: :system do
  it "removes the flash after a few seconds", :js do
    user = create(:user)
    login_as(user)

    visit(new_plant_path)
    fill_in("Name", with: "Snake Plant")
    click_button("Create Plant")
    wait_for_stimulus("flash")

    expect(page).to have_css("[data-role=flash]", text: "Plant was created.")
    expect(page).to have_no_css("[data-role=flash]", wait: 10)
  end
end
