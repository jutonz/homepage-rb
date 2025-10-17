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

  it "manages payees" do
    user = create(:user)
    shared_bill = create(:shared_bill, user:)
    login_as(user)

    visit(shared_bill_path(shared_bill))

    expect(page).to have_content("No payees yet")
    click_on("New Payee")

    fill_in("Name", with: "Payee1")
    click_on("Create Payee")

    expect(page).to have_content("Payee Payee1 was added")
    expect(page).to have_css("[data-role='payee']", text: "Payee1")

    click_on("New Payee")
    fill_in("Name", with: "Payee2")
    click_on("Create Payee")

    expect(page).to have_content("Payee Payee2 was added")
    expect(page).to have_css("[data-role='payee']", count: 2)

    within("[data-role='payee']", text: "Payee1") do
      click_on("Edit")
    end

    fill_in("Name", with: "PayeeOne")
    click_on("Update Payee")

    expect(page).to have_content("Payee PayeeOne was updated")
    expect(page).to have_css("[data-role='payee']", text: "PayeeOne")

    within("[data-role='payee']", text: "Payee2") do
      click_on("Remove")
    end

    expect(page).to have_content("Payee Payee2 has been removed")
    expect(page).to have_css("[data-role='payee']", count: 1)
    expect(page).not_to have_css(
      "[data-role='payee']",
      text: "Payee2"
    )
  end

  it "manages bills" do
    user = create(:user)
    shared_bill = create(:shared_bill, user:)
    login_as(user)

    visit(shared_bill_path(shared_bill))

    expect(page).to have_content("No bills yet")
    click_on("New Bill")

    fill_in("Name", with: "January Bill")
    click_on("Create Bill")

    expect(page).to have_content("Bill January Bill was added")
    expect(page).to have_css("[data-role='bill']", text: "January Bill")

    click_on("New Bill")
    fill_in("Name", with: "February Bill")
    click_on("Create Bill")

    expect(page).to have_content("Bill February Bill was added")
    expect(page).to have_css("[data-role='bill']", count: 2)

    within("[data-role='bill']", text: "January Bill") do
      click_on("Edit")
    end

    fill_in("Name", with: "Jan 2025")
    click_on("Update Bill")

    expect(page).to have_content("Bill Jan 2025 was updated")
    expect(page).to have_css("[data-role='bill']", text: "Jan 2025")

    within("[data-role='bill']", text: "February Bill") do
      click_on("Remove")
    end

    expect(page).to have_content("Bill February Bill has been removed")
    expect(page).to have_css("[data-role='bill']", count: 1)
    expect(page).not_to have_css(
      "[data-role='bill']",
      text: "February Bill"
    )
  end
end
