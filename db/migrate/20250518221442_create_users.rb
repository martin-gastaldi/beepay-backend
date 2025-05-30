class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :user_name, null: false
      t.string :email, null: false
      t.timestamps
    end

    add_index :users, :user_name, unique: true
    add_index :users, :email, unique: true
  end
end