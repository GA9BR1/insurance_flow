module Types
  class PolicyInputType < Types::BaseInputObject
    argument :data_emissao, String, required: true, validates: { Validators::DateValidator => {field: "data_emissao"} }
    argument :data_fim_cobertura, String, required: true, validates: { Validators::DateValidator => {field: "data_fim_cobertura"} }
    argument :valor_premio, Float, required: true
    argument :segurado, Types::InsuredInputType, required: true
    argument :veiculo, Types::VehicleInputType, required: true
  end
end
