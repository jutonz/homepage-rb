require "rails_helper"

RSpec.describe Todo::RoomsController do
  describe "index" do
    it "shows rooms for the current user" do
      me = create(:user)
      my_room = create(:todo_room, user: me)
      not_my_room = create(:todo_room)
      login_as(me)

      get(todo_rooms_path)

      expect(page).to have_room(my_room)
      expect(page).not_to have_room(not_my_room)
    end
  end

  def have_room(room)
    have_css("[data-role=room]", text: room.name)
  end
end
