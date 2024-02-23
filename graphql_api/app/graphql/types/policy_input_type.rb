module Types
  class PolicyInputType < Types::BaseInputObject
    argument :data_emissao, String, required: true
    argument :data_fim_cobertura, String, required: true
    argument :segurado, Types::AssuredInputType, required: true
    argument :veiculo, Types::VehicleInputType, required: true
  end
end
