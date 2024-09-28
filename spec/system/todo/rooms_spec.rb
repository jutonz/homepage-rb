require "rails_helper"

RSpec.describe "Todo rooms" do
  it "allows creating rooms" do
    user = create(:user)
    login_as(user)

    visit(todo_rooms_path)
    click_link("New Room")

    fill_in("Name", with: "room name")
    click_button("Create Room")

    find("[data-role=room]", text: "room name")
  end
end
