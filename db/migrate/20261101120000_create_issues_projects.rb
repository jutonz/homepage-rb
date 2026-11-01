class CreateIssuesProjects < ActiveRecord::Migration[8.1]
  def change
    create_table(:issues_projects) do |t|
      t.references(:user, null: false, foreign_key: true, index: false)
      t.string(:name, null: false)
      t.string(:key, null: false)
      t.timestamps
    end

    add_index(
      :issues_projects,
      "user_id, lower(name)",
      unique: true,
      name: "index_issues_projects_on_user_id_and_lower_name"
    )
    add_index(
      :issues_projects,
      "user_id, lower(key)",
      unique: true,
      name: "index_issues_projects_on_user_id_and_lower_key"
    )
  end
end
