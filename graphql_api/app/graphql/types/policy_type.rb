# frozen_string_literal: true

module Types
  class PolicyType < Types::BaseObject
    field :policy_id, ID, null: false
    field :data_emissao, String, null: false
    field :data_fim_cobertura, String, null: false
    field :valor_premio, Float, null: false
    field :status, Types::PolicyStatusType, null: false
    field :link_pagamento, String, null: false
    field :segurado, Types::InsuredType, null: false
    field :veiculo, Types::VehicleType, null: false
  end
end
