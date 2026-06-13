require "rails_helper"

RSpec.describe "Plants inbox", type: :system do
  it "shows inbox images for the current user" do
    user = create(:user)
    other_user = create(:user)
    inbox_image = create(:plants_inbox_image, user:)
    other_image = create(:plants_inbox_image, user: other_user)
    login_as(user)

    visit(inbox_images_path)

    expect(page).to have_content("Images")
    expect(page).to have_content(
      "Taken #{inbox_image.taken_at.to_date}"
    )
    expect(page).to have_css(
      "[data-image-id='#{inbox_image.id}']"
    )
    expect(page).not_to have_css(
      "[data-image-id='#{other_image.id}']"
    )
  end

  it "adds inbox images from the index page" do
    user = create(:user)
    login_as(user)
    visit(inbox_images_path)

    click_link("Add Images")

    attach_file(
      "File",
      [
        Rails.root.join("spec/fixtures/files/audiosurf.jpg"),
        Rails.root.join("spec/fixtures/files/audiosurf.jpg")
      ]
    )
    fill_in("Taken at", with: "2024-01-02")
    click_button("Add Images")

    expect(page).to have_content("Images were added.")
    expect(page).to have_content("Taken 2024-01-02")
    expect(page).to have_css("img")
  end

  it "deletes an image" do
    user = create(:user)
    inbox_image = create(:plants_inbox_image, user:)
    login_as(user)

    visit(inbox_images_path)

    find(
      "[data-image-id='#{inbox_image.id}'] a"
    ).click

    expect(page).to have_content("Image")
    expect(page).to have_content(
      "Taken #{inbox_image.taken_at.to_date}"
    )

    click_button("Delete")

    expect(page).to have_content("Image was deleted.")
    expect(page).not_to have_css(
      "[data-image-id='#{inbox_image.id}']"
    )
  end

  it "assigns an inbox image to a plant from the show page" do
    user = create(:user)
    create(:plant, user:, name: "Pothos")
    inbox_image = create(:plants_inbox_image, user:)
    login_as(user)
    visit(inbox_image_path(inbox_image))

    click_button("Assign")

    expect(page).to have_content("Image was assigned.")
    expect(page).to have_content("Pothos")
    expect(page).to have_css("img")
  end
end
