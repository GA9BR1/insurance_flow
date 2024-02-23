module Types
    class AssuredType < Types::BaseObject
        field :nome, String , null: false
        field :cpf, String, null: false
    end
end
