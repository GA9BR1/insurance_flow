class Policy < ApplicationRecord
  belongs_to :assured
  belongs_to :vehicle
  validates :issue_date, presence: true
  validates :coverage_end, presence: true
  accepts_nested_attributes_for :assured, :vehicle
end
