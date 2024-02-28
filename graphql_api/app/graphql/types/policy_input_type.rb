module Types
  class PolicyInputType < Types::BaseInputObject
    argument :data_emissao, String, required: true, validates: {format: {with: /\d{4}-\d{2}-\d{2}/}}
    argument :data_fim_cobertura, String, required: true, validates: {format: {with: /\d{4}-\d{2}-\d{2}/}}
    argument :segurado, Types::InsuredInputType, required: true
    argument :veiculo, Types::VehicleInputType, required: true
  end
end
