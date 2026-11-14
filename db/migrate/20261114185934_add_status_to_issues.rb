class AddStatusToIssues < ActiveRecord::Migration[8.1]
  def change
    create_enum(
      :issue_status,
      ["Backlog", "Ready", "In Progress", "In Review", "Done", "Cancelled"]
    )
    add_column(
      :issues,
      :status,
      :enum,
      enum_type: :issue_status,
      null: false,
      default: "Backlog"
    )
  end
end
