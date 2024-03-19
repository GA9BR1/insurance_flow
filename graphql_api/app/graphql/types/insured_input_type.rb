module Types
  class InsuredInputType < Types::BaseInputObject
    argument :nome, String, required: true
    argument :cpf, String, required: true
    argument :email, String, required: true
  end
end
