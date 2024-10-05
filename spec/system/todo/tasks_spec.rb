require "rails_helper"

RSpec.describe "Todo tasks" do
  it "allows creating tasks" do
    user = create(:user)
    login_as(user)

    visit(todo_tasks_path)
    expect(page).to have_text("No tasks")

    click_link("New Task")
    fill_in("Name", with: "task name")
    click_button("Create Task")

    find("[data-role=task]", text: "task name")
    expect(page).not_to have_text("No tasks")
  end

  it "allows editing a task" do
    user = create(:user)
    task = create(:todo_task, user:, name: "before")
    login_as(user)

    visit(todo_task_path(task))

    click_link("Edit")
    fill_in("Name", with: "after")
    click_button("Update Task")

    find("h1", text: "after")
  end

  it "allows deleting a task" do
    user = create(:user)
    task = create(:todo_task, user:)
    login_as(user)

    visit(todo_task_path(task))

    accept_confirm do
      click_button("Delete")
    end

    expect(page).not_to have_css("h1", text: task.name)
  end
end
