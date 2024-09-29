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

  describe "create" do
    it "redirects" do
      user = create(:user)
      login_as(user)
      params = {todo_room: {name: "hi"}}

      post(todo_rooms_path, params:)

      expect(response).to redirect_to(todo_rooms_path)
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {todo_room: {name: ""}}

      post(todo_rooms_path, params:)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(page).to have_text("can't be blank")
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      room = create(:todo_room, user:)
      login_as(user)
      params = {todo_room: {name: "after"}}

      put(todo_room_path(room), params:)

      expect(response).to redirect_to(todo_room_path(room))
      expect(room.reload).to have_attributes(params[:todo_room])
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {todo_room: {name: ""}}

      post(todo_rooms_path, params:)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(page).to have_text("can't be blank")
    end
  end

  def have_room(room)
    have_css("[data-role=room]", text: room.name)
  end
end
