module TodoistApiMocks
  def self.mock_tasks_get(task)
    FakeTodoist
      .stub(:get, "/api/v1/tasks/#{task.id}")
      .to_return(
        status: 200,
        body: task.to_json,
        headers: {"content-type" => "application/json"}
      )
  end

  def self.mock_tasks_create(task)
    FakeTodoist
      .stub(:post, "/api/v1/tasks")
      .to_return(
        status: 200,
        body: task.to_json,
        headers: {"content-type" => "application/json"}
      )
  end

  def self.mock_tasks_rollable(tasks)
    FakeTodoist
      .stub(:get, "/api/v1/tasks/filter?query=@rollable,overdue")
      .to_return(
        status: 200,
        body: {
          results: Array(tasks),
          next_cursor: nil
        }.to_json,
        headers: {"content-type" => "application/json"}
      )
  end

  def self.mock_task_update(task, result:)
    FakeTodoist
      .stub(:post, "/api/v1/tasks/#{task.id}")
      .to_return(
        status: 200,
        body: result.to_json,
        headers: {"content-type" => "application/json"}
      )
  end
end
