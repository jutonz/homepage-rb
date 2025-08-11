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

    it "requires authentication" do
      get(todo_rooms_path)

      expect(response).to redirect_to(new_session_path)
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

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end

    it "requires authentication" do
      params = {todo_room: {name: "hello"}}

      post(todo_rooms_path, params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "show" do
    it "has crumbs" do
      room = create(:todo_room)
      login_as(room.user)

      get(todo_room_path(room))

      expect(page).to have_link("Todo", href: todo_path)
      expect(page).to have_link("Rooms", href: todo_rooms_path)
    end

    it "has an empty state if no tasks" do
      room = create(:todo_room)
      login_as(room.user)

      get(todo_room_path(room))

      expect(page).to have_text("This room doesn't have any tasks yet")
      expect(page).to have_link(
        "Add one",
        href: new_todo_task_path(todo_task: {room_ids: [room.id]})
      )
    end

    it "returns 404 when viewing room not owned by current user" do
      room = create(:todo_room)
      other_user = create(:user)
      login_as(other_user)

      get(todo_room_path(room))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      room = create(:todo_room)

      get(todo_room_path(room))

      expect(response).to redirect_to(new_session_path)
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

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end

    it "returns 404 when updating room not owned by current user" do
      room = create(:todo_room)
      other_user = create(:user)
      login_as(other_user)
      params = {todo_room: {name: "updated"}}

      put(todo_room_path(room), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      room = create(:todo_room)
      params = {todo_room: {name: "updated"}}

      put(todo_room_path(room), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "edit" do
    it "has crumbs" do
      room = create(:todo_room)
      login_as(room.user)

      get(edit_todo_room_path(room))

      expect(page).to have_link("Todo", href: todo_path)
      expect(page).to have_link("Rooms", href: todo_rooms_path)
      expect(page).to have_link(room.name, href: todo_room_path(room))
    end

    it "returns 404 when editing room not owned by current user" do
      room = create(:todo_room)
      other_user = create(:user)
      login_as(other_user)

      get(edit_todo_room_path(room))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      room = create(:todo_room)

      get(edit_todo_room_path(room))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "new" do
    it "requires authentication" do
      get(new_todo_room_path)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "destroy" do
    it "returns 404 when destroying room not owned by current user" do
      room = create(:todo_room)
      other_user = create(:user)
      login_as(other_user)

      delete(todo_room_path(room))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      room = create(:todo_room)

      delete(todo_room_path(room))

      expect(response).to redirect_to(new_session_path)
    end
  end

  def have_room(room)
    have_css("[data-role=room]", text: room.name)
  end
end
