class CreateSharedBillsTables < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_bills_shared_bills do |t|
      t.string(:name, null: false)
      t.references(:user, null: false, foreign_key: true)
      t.timestamps
    end

    create_table :shared_bills_payees do |t|
      t.string(:name, null: false)
      t.references(
        :shared_bill,
        null: false,
        foreign_key: {to_table: :shared_bills_shared_bills}
      )
      t.timestamps
    end

    create_table :shared_bills_bills do |t|
      t.string(:name, null: false)
      t.references(
        :shared_bill,
        null: false,
        foreign_key: {to_table: :shared_bills_shared_bills}
      )
      t.timestamps
    end

    create_table :shared_bills_payee_bills do |t|
      t.references(
        :bill,
        null: false,
        foreign_key: {to_table: :shared_bills_bills}
      )
      t.references(
        :payee,
        null: false,
        foreign_key: {to_table: :shared_bills_payees}
      )
      t.integer(:amount, null: false)
      t.boolean(:paid, null: false, default: false)
      t.timestamps
    end

    add_index(
      :shared_bills_payee_bills,
      [:bill_id, :payee_id],
      unique: true
    )
  end
end
