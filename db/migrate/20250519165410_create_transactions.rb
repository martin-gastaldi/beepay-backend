class CreateTransactions < ActiveRecord::Migration[8.0]
  def change # Método que define los cambios a realizar en la base de datos.
    create_table :transactions do |t| # Crea la tabla 'transactions' con las siguientes columnas:
      t.references :source_account, null: false, foreign_key: {to_table: :accounts} # Referencias a las cuentas de origen y destino, deben existir en la tabla 'accounts'.
      t.references :target_account, null: false, foreign_key: {to_table: :accounts} 
      t.integer :amount, null: false # Monto de la transacción, debe ser un número entero positivo.
      t.string :reason # Motivo de la transacción, opcional.
      t.timestamps
    end
  end
end
