class Insured < ApplicationRecord
  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true
  validates :email, presence: true
  has_one :policy
end
