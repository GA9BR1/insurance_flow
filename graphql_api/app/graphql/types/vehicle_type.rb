module Types
    class VehicleType < Types::BaseObject
        field :marca, String , null: false
        field :modelo, String , null: false
        field :ano, String , null: false
        field :placa, String , null: false
    end
end
