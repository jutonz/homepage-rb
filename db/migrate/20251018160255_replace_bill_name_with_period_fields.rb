class ReplaceBillNameWithPeriodFields < ActiveRecord::Migration[8.0]
  def change
    # Delete all existing bills and their payee_bills
    reversible do |dir|
      dir.up do
        execute("DELETE FROM shared_bills_payee_bills")
        execute("DELETE FROM shared_bills_bills")
      end
    end

    # Replace name with period fields
    remove_column(:shared_bills_bills, :name, :string)
    add_column(:shared_bills_bills, :period_start, :datetime, null: false)
    add_column(:shared_bills_bills, :period_end, :datetime, null: false)
  end
end
