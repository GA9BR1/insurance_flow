class Policy < ApplicationRecord
  belongs_to :assured
  belongs_to :vehicle
end
