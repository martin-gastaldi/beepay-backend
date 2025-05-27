require 'bcrypt'
class User < ActiveRecord::Base
    has_one :account
    has_secure_password # utiliza bcrypt para manejar el hash de la contraseña
    
    validates :user_name, presence: true, uniqueness: true # validación de presencia y unicidad del nombre de usuario
    validates :email, presence: true, uniqueness: true # validación de presencia y unicidad del correo electrónico
end