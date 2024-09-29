require "rails_helper"

RSpec.describe "Todo rooms" do
  it "allows creating rooms" do
    user = create(:user)
    login_as(user)

    visit(todo_rooms_path)
    expect(page).to have_text("No rooms")

    click_link("New Room")
    fill_in("Name", with: "room name")
    click_button("Create Room")

    find("[data-role=room]", text: "room name")
    expect(page).not_to have_text("No rooms")
  end

  it "allows editing a room" do
    user = create(:user)
    room = create(:todo_room, user:, name: "before")
    login_as(user)

    visit(todo_room_path(room))

    click_link("Edit")
    fill_in("Name", with: "after")
    click_button("Update Room")

    find("[data-role=room-name]", text: "after")
  end

  it "allows deleting a room" do
    user = create(:user)
    room = create(:todo_room, user:)
    login_as(user)

    visit(todo_room_path(room))

    accept_confirm do
      click_button("Delete")
    end

    expect(page).not_to have_css(
      "[data-role=room]", text: room.name
    )
  end
end
