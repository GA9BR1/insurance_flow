# frozen_string_literal: true

module Types
  class PolicyType < Types::BaseObject
    field :policy_id, ID, null: false
    field :data_emissao, String, null: false
    field :data_fim_cobertura, String, null: false
    field :segurado, Types::AssuredType, null: false
    field :veiculo, Types::VehicleType, null: false
  end
end
