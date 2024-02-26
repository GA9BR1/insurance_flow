module Types
    class InsuredType < Types::BaseObject
        field :nome, String , null: false
        field :cpf, String, null: false
    end
end
