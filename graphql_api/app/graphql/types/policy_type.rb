# frozen_string_literal: true

module Types
  class PolicyType < Types::BaseObject
    field :id, ID, null: false
    field :issue_date, String, null: false
    field :coverage_end, String, null: false
    field :assured, Types::AssuredType, null: false
    field :vehicle, Types::VehicleType, null: false
  end
end