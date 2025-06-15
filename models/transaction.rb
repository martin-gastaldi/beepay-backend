# esta clase representa una transacción entre dos cuentas
class Transaction < ActiveRecord::Base
    # Establece la relación entre la transacción y las cuentas de origen y destino.
    # Se asume que hay un modelo 'Account' definido en otro lugar.
    belongs_to :source_account, class_name: 'Account'
    belongs_to :target_account, class_name: 'Account'
    
    validates :source_account_id, presence: true
    validates :target_account_id, presence: true
    validates :amount, numericality: {only_integer: true, greater_than: 0}
    validate :accounts_must_be_different
    validate :source_account_has_enough_balance

    after_create :transfer_balance

    private

    # Método que se ejecuta después de crear una transacción.
    # Realiza la transferencia de saldo entre la cuenta de origen y la cuenta de destino.
    # Se utiliza una transacción de base de datos para asegurar que ambas operaciones se realicen correctamente.
    # Si alguna de las operaciones falla, se revertirán ambas.
    def transfer_balance
        ActiveRecord::Base.transaction do
        source_account.balance -= amount
        source_account.save!
        target_account.balance += amount
        target_account.save!
        end
    end

    # Valida que la cuenta de origen y la cuenta de destino sean diferentes.
    def accounts_must_be_different
        if source_account_id == target_account_id
            errors.add(:target_account_id, "must be different from source account.")
        end
    end
    # Valida que la cuenta de origen tenga suficiente saldo para realizar la transacción.
    # Si el saldo de la cuenta de origen es menor que el monto de la transacción, se agrega un error.
    def source_account_has_enough_balance
        if source_account && source_account.balance < amount
            errors.add(:amount, "exceeds the source account balance.")
        end
    end
end