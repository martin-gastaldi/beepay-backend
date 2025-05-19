class Transaction < ActiveRecord::Base
    belongs_to :source_account, class_name: 'Account'
    belongs_to :target_account, class_name: 'Account'
    
    validates :source_account_id, presence: true
    validates :target_account_id, presence: true
    validates :amount, numericality: {only_integer: true, greater_than: 0}
    validate :accounts_must_be_different
    validate :source_account_has_enough_balance

    def accounts_must_be_different
        if source_account_id == target_account_id
            errors.add(:target_account_id, "must be different from source account.")
        end
    end

    def source_account_has_enough_balance
        if source_account.balance < amount
            errors.add(:amount, "exceeds the source account balance.")
        end
    end

    after_create :transfer_balance

    private

    def transfer_balance
        ActiveRecord::Base.transaction do
        source_account.balance -= amount
        source_account.save!

        target_account.balance += amount
        target_account.save!
        end
    end
end