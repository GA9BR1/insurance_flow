class Policy < ApplicationRecord
  belongs_to :insured
  belongs_to :vehicle
  validates :issue_date, presence: true, format: { with: /\d{4}\-\d{2}\-\d{2}/ }
  validates :coverage_end, presence: true, format: { with: /\d{4}\-\d{2}\-\d{2}/ }
  validates_with DateValidator
  accepts_nested_attributes_for :insured, :vehicle
end
