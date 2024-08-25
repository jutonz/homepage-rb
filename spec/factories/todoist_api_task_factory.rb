FactoryBot.define do
  factory :todoist_api_task, class: "Todoist::Api::Tasks::Task" do
    skip_create
    initialize_with { Todoist::Api::Tasks::Task.new(**attributes) }

    assignee_id { "123" }
    assigner_id { "123" }
    content { "Do something" }
    creator_id { "123" }
    description { "Please?" }
    sequence(:id) { _1.to_s }
    is_completed { false }
    priority { 1 }
    project_id { "123" }
  end
end
