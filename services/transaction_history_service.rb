# app/services/transaction_history_service.rb

# Este servicio obtiene el historial de transacciones de una cuenta
# Este servicio se encarga de recuperar el historial de transacciones de una cuenta específica.
# Se asume que hay un modelo 'Transaction' definido en otro lugar.

# services/transaction_history_service.rb
class TransactionHistoryService
  def initialize(account)
    @account = account
  end

  def call
    {
      sent: @account.source_transactions.includes(:target_account),
      received: @account.target_transactions.includes(:source_account)
    }
  end
end
