module Types
  class AssuredInputType < Types::BaseInputObject
    argument :nome, String, required: true
    argument :cpf, String, required: true
  end
end
