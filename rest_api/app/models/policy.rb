class Policy < ApplicationRecord
  belongs_to :insured
  belongs_to :vehicle
  validates :issue_date, presence: true
  validates :coverage_end, presence: true
  accepts_nested_attributes_for :insured, :vehicle
end
