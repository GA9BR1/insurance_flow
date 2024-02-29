module Types
  class PolicyInputType < Types::BaseInputObject
    argument :data_emissao, String, required: true, validates: { Validators::DateValidator => {} }
    argument :data_fim_cobertura, String, required: true, validates: { Validators::DateValidator => {} }
    argument :segurado, Types::InsuredInputType, required: true
    argument :veiculo, Types::VehicleInputType, required: true
  end
end
