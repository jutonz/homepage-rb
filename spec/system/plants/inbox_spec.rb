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
end
