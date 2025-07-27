require "rails_helper"

RSpec.describe "Galleries page" do
  it "displays galleries with metadata" do
    user = create(:user)
    gallery1 = create(:gallery, user:, name: "Nature")
    create(:gallery, user:, name: "Portrait")
    create_list(:galleries_image, 3, gallery: gallery1)
    create_list(:galleries_tag, 2, gallery: gallery1)
    login_as(user)

    visit(galleries_path)

    expect(page).to have_content("Galleries")
    expect(page).to have_css("[data-role='gallery']", count: 2)

    within("[data-role='gallery']", text: "Nature") do
      expect(page).to have_content("Nature")
      expect(page).to have_content("3 images")
      expect(page).to have_content("2 tags")
    end

    within("[data-role='gallery']", text: "Portrait") do
      expect(page).to have_content("Portrait")
      expect(page).to have_content("0 images")
      expect(page).to have_content("0 tags")
    end
  end

  it "shows empty state when no galleries exist" do
    user = create(:user)
    login_as(user)

    visit(galleries_path)

    expect(page).to have_content("No galleries yet")
    expect(page).to have_content("Create your first gallery to get started")
    expect(page).not_to have_css("[data-role='gallery']")
  end

  it "links to individual gallery pages" do
    user = create(:user)
    gallery = create(:gallery, user:, name: "Landscapes")
    login_as(user)

    visit(galleries_path)

    click_on("Landscapes")

    expect(current_path).to eq(gallery_path(gallery))
    expect(page).to have_content("Landscapes")
  end

  it "manages a gallery" do
    user = create(:user)
    login_as(user)

    visit(galleries_path)
    click_on("New Gallery")

    fill_in("Name", with: "Travel Photos")
    click_on("Create Gallery")

    expect(page).to have_content("Gallery was successfully created")
    expect(page).to have_content("Travel Photos")

    click_on("Edit")
    fill_in("Name", with: "Amazing Travel Photos")
    click_on("Update Gallery")

    expect(page).to have_content("Gallery was successfully updated")
    expect(page).to have_content("Amazing Travel Photos")

    click_on("Delete")

    expect(page).to have_content("Gallery was successfully destroyed")
    expect(current_path).to eq(galleries_path)
    expect(page).not_to have_content("Amazing Travel Photos")
  end
end
