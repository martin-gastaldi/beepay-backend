class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|  #debe ser en plural
      t.string :name  #columna
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
