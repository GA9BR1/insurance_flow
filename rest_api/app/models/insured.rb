class Insured < ApplicationRecord
  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true
  has_one :policy
end
