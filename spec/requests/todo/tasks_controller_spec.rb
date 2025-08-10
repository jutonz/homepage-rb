require "rails_helper"

RSpec.describe Todo::TasksController do
  describe "index" do
    it "shows tasks for the current user" do
      me = create(:user)
      my_task = create(:todo_task, user: me)
      not_my_task = create(:todo_task)
      login_as(me)

      get(todo_tasks_path)

      expect(page).to have_task(my_task)
      expect(page).not_to have_task(not_my_task)
    end
  end

  describe "new" do
    it "can prefill params" do
      user = create(:user)
      login_as(user)
      room = create(:todo_room, user:)
      params = {todo_task: {
        name: "hi",
        room_ids: [room.id]
      }}

      get(new_todo_task_path, params:)

      expect(response).to have_http_status(:ok)
      expect(page).to have_field("Name", with: "hi")
      expect(page).to have_field(room.name, checked: true)
    end
  end

  describe "create" do
    it "redirects" do
      user = create(:user)
      login_as(user)
      room_ids = create_pair(:todo_room, user:).map(&:id)
      params = {todo_task: {
        name: "hi",
        room_ids:
      }}

      post(todo_tasks_path, params:)

      expect(response).to redirect_to(todo_tasks_path)
      task = Todo::Task.last
      expect(task.name).to eql("hi")
      expect(task.room_ids).to match_array(room_ids)
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {todo_task: {name: ""}}

      post(todo_tasks_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end

    it "doesn't allow assigning to other people's rooms" do
      user, other_user = create_pair(:user)
      login_as(user)
      my_room_id = create(:todo_room, user:).id
      other_room_id = create(:todo_room, user: other_user).id
      params = {todo_task: {
        name: "hi",
        room_ids: [my_room_id, other_room_id]
      }}

      post(todo_tasks_path, params:)

      expect(response).to redirect_to(todo_tasks_path)
      expect(Todo::Task.last.room_ids).to eql([my_room_id])
    end
  end

  describe "show" do
    it "has crumbs" do
      task = create(:todo_task)
      login_as(task.user)

      get(todo_task_path(task))

      expect(page).to have_link("Todo", href: todo_path)
      expect(page).to have_link("Tasks", href: todo_tasks_path)
    end

    it "links to rooms" do
      task = create(:todo_task, :with_room)
      room = task.rooms.first
      login_as(task.user)

      get(todo_task_path(task))

      expect(response).to have_http_status(:ok)
      expect(page).to have_link(room.name, href: todo_room_path(room))
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      task = create(:todo_task, user:)
      login_as(user)
      params = {todo_task: {name: "after"}}

      put(todo_task_path(task), params:)

      expect(response).to redirect_to(todo_task_path(task))
      expect(task.reload).to have_attributes(params[:todo_task])
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {todo_task: {name: ""}}

      post(todo_tasks_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_text("can't be blank")
    end
  end

  describe "edit" do
    it "has crumbs" do
      task = create(:todo_task)
      login_as(task.user)

      get(edit_todo_task_path(task))

      expect(page).to have_link("Todo", href: todo_path)
      expect(page).to have_link("Tasks", href: todo_tasks_path)
      expect(page).to have_link(task.name, href: todo_task_path(task))
    end
  end

  describe "authorization" do
    describe "index" do
      it "requires authentication" do
        get(todo_tasks_path)

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "show" do
      it "returns 404 when viewing task not owned by current user" do
        task = create(:todo_task)
        other_user = create(:user)
        login_as(other_user)

        get(todo_task_path(task))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        task = create(:todo_task)

        get(todo_task_path(task))

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "create" do
      it "requires authentication" do
        params = {todo_task: {name: "hello"}}

        post(todo_tasks_path, params:)

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "update" do
      it "returns 404 when updating task not owned by current user" do
        task = create(:todo_task)
        other_user = create(:user)
        login_as(other_user)
        params = {todo_task: {name: "updated"}}

        put(todo_task_path(task), params:)

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        task = create(:todo_task)
        params = {todo_task: {name: "updated"}}

        put(todo_task_path(task), params:)

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "destroy" do
      it "returns 404 when destroying task not owned by current user" do
        task = create(:todo_task)
        other_user = create(:user)
        login_as(other_user)

        delete(todo_task_path(task))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        task = create(:todo_task)

        delete(todo_task_path(task))

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "edit" do
      it "returns 404 when editing task not owned by current user" do
        task = create(:todo_task)
        other_user = create(:user)
        login_as(other_user)

        get(edit_todo_task_path(task))

        expect(response).to have_http_status(:not_found)
      end

      it "requires authentication" do
        task = create(:todo_task)

        get(edit_todo_task_path(task))

        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "new" do
      it "requires authentication" do
        get(new_todo_task_path)

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  def have_task(task)
    have_css("[data-role=task]", text: task.name)
  end
end
