require_relative 'spec_helper'

RSpec.describe Transaction do
  # Se limpia la base de datos (solo la de Test) para correr sin inconvenientes las pruebas.
  before(:each) do
    Transaction.delete_all
    Account.delete_all
    User.delete_all
  end

  # Se crean dos usuarios y dos cuentas para los tests.
  let!(:source_user) { User.create!(user_name: "Usuario1", email: "usuario1@gmail.com", password_digest: "123A") }
  let!(:target_user) { User.create!(user_name: "Usuario2", email: "usuario2@gmail.com", password_digest: "456B") }
  let!(:source_account) { Account.create!(user_id: source_user.id, cbu_cvu: "123", alias: "A", balance: 100) }
  let!(:target_account) { Account.create!(user_id: target_user.id, cbu_cvu: "456", alias: "B", balance: 50) }

  context 'validations' do
    # Test 1: Transacción incorrecta por saldo insuficiente.
    it 'no permite crear transacción si no hay saldo suficiente' do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: target_account,
        amount: 150
      )
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include("exceeds the source account balance.")
    end

    # Test 2: Transacción incorrecta por ser la cuenta origen la misma que la cuenta destino.
    it 'no permite crear transacción si las cuentas de origen y destino son la misma' do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: source_account,
        amount: 150
      )
      expect(transaction).not_to be_valid
      expect(transaction.errors[:target_account_id]).to include("must be different from source account.")
    end

    # Test 3: Transacción correcta.
    it 'permite crear transacción si hay saldo suficiente' do
      transaction = Transaction.new(
        source_account: source_account,
        target_account: target_account,
        amount: 50
      )
      expect(transaction).to be_valid
    end
  end

  context 'after create callback' do
    # Test 4: Movimiento exitoso de dinero de una cuenta a la otra.
    it 'debita y acredita los balances correctamente' do
      transaction = Transaction.create!(
        source_account: source_account,
        target_account: target_account,
        amount: 40
      )
      expect(source_account.reload.balance).to eq(60)
      expect(target_account.reload.balance).to eq(90)
    end
  end
end