class AddNumbersToIssues < ActiveRecord::Migration[8.1]
  def up
    add_column(
      :issues_projects,
      :last_issue_number,
      :integer,
      null: false,
      default: 0
    )
    add_column(:issues, :number, :integer)

    execute(<<~SQL)
      UPDATE issues
      SET number = numbered.number
      FROM (
        SELECT
          id,
          ROW_NUMBER() OVER (
            PARTITION BY project_id ORDER BY created_at, id
          ) AS number
        FROM issues
      ) AS numbered
      WHERE issues.id = numbered.id
    SQL
    execute(<<~SQL)
      UPDATE issues_projects
      SET last_issue_number = counts.last_number
      FROM (
        SELECT project_id, MAX(number) AS last_number
        FROM issues
        GROUP BY project_id
      ) AS counts
      WHERE issues_projects.id = counts.project_id
    SQL

    change_column_null(:issues, :number, false)
    add_index(:issues, %i[project_id number], unique: true)
  end

  def down
    remove_index(:issues, %i[project_id number])
    remove_column(:issues, :number)
    remove_column(:issues_projects, :last_issue_number)
  end
end
