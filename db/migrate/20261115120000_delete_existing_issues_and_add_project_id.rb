class DeleteExistingIssuesAndAddProjectId < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL)
      DELETE FROM active_storage_attachments
      WHERE record_type = 'ActionText::RichText'
        AND record_id IN (
          SELECT id FROM action_text_rich_texts WHERE record_type = 'Issue'
        )
    SQL
    execute("DELETE FROM action_text_rich_texts WHERE record_type = 'Issue'")
    execute("DELETE FROM issues")

    add_reference(
      :issues,
      :project,
      null: false,
      foreign_key: {to_table: :issues_projects}
    )
  end

  def down
    remove_reference(
      :issues,
      :project,
      foreign_key: {to_table: :issues_projects}
    )
  end
end
