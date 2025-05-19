class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :source_account, null: false, foreign_key: {to_table: :accounts}
      t.references :target_account, null: false, foreign_key: {to_table: :accounts}
      t.integer :amount, null: false
      t.string :reason
      t.timestamps
    end
  end
end
