class RenameAmountToAmountCentsOnPayeeBills < ActiveRecord::Migration[8.0]
  def change
    rename_column(:shared_bills_payee_bills, :amount, :amount_cents)
  end
end
