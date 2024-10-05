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

  describe "create" do
    it "redirects" do
      user = create(:user)
      login_as(user)
      params = {todo_task: {name: "hi"}}

      post(todo_tasks_path, params:)

      expect(response).to redirect_to(todo_tasks_path)
    end

    it "shows error messages" do
      user = create(:user)
      login_as(user)
      params = {todo_task: {name: ""}}

      post(todo_tasks_path, params:)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(page).to have_text("can't be blank")
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

      expect(response).to have_http_status(:unprocessable_entity)
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

  def have_task(task)
    have_css("[data-role=task]", text: task.name)
  end
end
