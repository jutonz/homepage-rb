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
    labels { ["rollable"] }
    due do
      association(
        :todoist_api_task_due,
        date: due_date,
        string: due_string,
        is_recurring: due_is_recurring
      )
    end

    transient do
      due_date { Date.current }
      due_string { "today" }
      due_is_recurring { false }
    end

    trait :recurring do
      due_string { "every! 3 days" }
      due_is_recurring { true }
    end
  end

  factory :todoist_api_task_due, class: "Todoist::Api::Tasks::Due" do
    skip_create
    initialize_with { Todoist::Api::Tasks::Due.new(**attributes) }

    date { Date.current }
    string { "today" }
    is_recurring { false }
  end
end
