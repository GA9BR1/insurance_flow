class Vehicle < ApplicationRecord
  validates :plate, presence: true, uniqueness: true
  validates :brand, presence: true
  validates :model, presence: true
  validates :year, presence: true
  has_one :policy
end
