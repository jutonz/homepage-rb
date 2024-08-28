module TodoistApiMocks
  def self.mock_tasks_create(task = FactoryBot.build(:todoist_api_task))
    WebMock::API.stub_request(
      :post,
      "https://api.todoist.com/rest/v2/tasks"
    ).to_return(
      status: 200,
      body: task.to_json,
      headers: {"content-type" => "application/json"}
    )
  end

  def self.mock_tasks_rollable(tasks)
    WebMock::API.stub_request(
      :get,
      "https://api.todoist.com/rest/v2/tasks?filter=@rollable,today"
    ).to_return(
      status: 200,
      body: Array(tasks).to_json,
      headers: {"content-type" => "application/json"}
    )
  end

  def self.mock_task_update(task, result:)
    WebMock::API
      .stub_request(:post, "https://api.todoist.com/rest/v2/tasks/#{task.id}")
      .to_return(
        status: 200,
        body: result.to_json,
        headers: {"content-type" => "application/json"}
      )
  end
end
