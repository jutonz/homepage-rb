require "rails_helper"

RSpec.describe "Shared Bills page" do
  it "displays shared bills" do
    user = create(:user)
    shared_bills = create_pair(:shared_bill, user:)
    login_as(user)

    visit(shared_bills_path)

    expect(page).to have_content("Shared Bills")
    expect(page).to have_css(
      "[data-role='shared-bill']",
      count: 2
    )

    shared_bills.each do |shared_bill|
      expect(page).to have_css(
        "[data-role='shared-bill']",
        text: shared_bill.name
      )
    end
  end

  it "shows empty state when no shared bills exist" do
    user = create(:user)
    login_as(user)

    visit(shared_bills_path)

    expect(page).to have_content("No shared bills yet")
    expect(page).to have_content(
      "Create your first shared bill to start tracking"
    )
    expect(page).not_to have_css("[data-role='shared-bill']")
  end

  it "manages a shared bill" do
    user = create(:user)
    login_as(user)

    visit(shared_bills_path)
    click_on("New Shared Bill")

    fill_in("Name", with: "Phone Bill")
    click_on("Create Shared bill")

    expect(page).to have_content(
      "Shared bill was successfully created"
    )
    expect(page).to have_content("Phone Bill")

    click_on("Edit")
    fill_in("Name", with: "Mobile Phone Bill")
    click_on("Update Shared bill")

    expect(page).to have_content(
      "Shared bill was successfully updated"
    )
    expect(page).to have_content("Mobile Phone Bill")

    click_on("Delete")

    expect(page).to have_content(
      "Shared bill was successfully destroyed"
    )
    expect(current_path).to eq(shared_bills_path)
    expect(page).not_to have_content("Mobile Phone Bill")
  end
end
