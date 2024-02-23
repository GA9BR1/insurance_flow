module Types
    class VehicleType < Types::BaseObject
        field :String :brand, null: false
        field :String :model, null: false
        field :String :year, null: false
        field :String :plate, null: false
    end
end