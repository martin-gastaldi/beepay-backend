class Account < ActiveRecord::Base
    belongs_to :user
    has_many :source_transactions, class_name: 'Transaction', foreign_key: :source_account_id
    has_many :target_transactions, class_name: 'Transaction', foreign_key: :target_account_id
    
    validates :cbu_cvu, presence: true, uniqueness: true
    validates :alias, presence: true, uniqueness: true
    validates :balance, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end