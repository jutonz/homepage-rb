class DropSolidQueueTablesFromPrimary < ActiveRecord::Migration[8.1]
  # Six tables have foreign keys to solid_queue_jobs, so it is last.
  TABLES = %w[
    solid_queue_blocked_executions
    solid_queue_claimed_executions
    solid_queue_failed_executions
    solid_queue_pauses
    solid_queue_processes
    solid_queue_ready_executions
    solid_queue_recurring_executions
    solid_queue_recurring_tasks
    solid_queue_scheduled_executions
    solid_queue_semaphores
    solid_queue_jobs
  ].freeze

  def up
    ensure_tables_are_empty
    TABLES.each { |table| drop_table(table) }
  end

  def down
    raise(ActiveRecord::IrreversibleMigration)
  end

  def ensure_tables_are_empty
    nonempty_tables = TABLES.filter_map do |table|
      count = connection.select_value("SELECT COUNT(*) FROM #{table}")
      "#{table} (#{count})" if count.positive?
    end
    return if nonempty_tables.empty?

    raise("Solid Queue tables contain rows: #{nonempty_tables.join(", ")}")
  end
end
