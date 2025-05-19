class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :cbu_cvu, null: false
      t.string :alias, null: false
      t.integer :balance, null: false
      t.timestamps
    end

    add_index :accounts, :cbu_cvu, unique: true
    add_index :accounts, :alias, unique: true 
  end
end
