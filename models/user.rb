# models/user.rb
class User < ActiveRecord::Base
    # Si más adelante usás bcrypt para hashear contraseñas
    # require 'bcrypt'
    # has_secure_password
  
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
  end
  