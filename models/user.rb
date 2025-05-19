class User < ActiveRecord::Base
    has_one :account
    
    validates :user_name, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true
end