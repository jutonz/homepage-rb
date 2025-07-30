FactoryBot.define do
  factory :todoist_api_task, class: "Todoist::Api::Tasks::Task" do
    skip_create
    initialize_with { Todoist::Api::Tasks::Task.new(**attributes) }

    sequence(:id) { "6cVrPg9WXPhx4X#{it}" }
    project_id { "6JRjhMXMmhwq3WVX" }
    labels { ["rollable"] }
    added_at { Time.parse("2025-07-30T12:06:03.257775Z") }
    completed_at { nil }
    content { "Do something" }
    description { "Please?" }

    due do
      association(
        :todoist_api_task_due,
        date: due_date,
        string: due_string,
        is_recurring: due_is_recurring
      )
    end

    transient do
      due_date { Time.current }
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

    date { Time.current }
    string { "today" }
    is_recurring { false }
  end
end
