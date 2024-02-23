module Types
  class VehicleInputType < Types::BaseInputObject
    argument :marca, String , required: true
    argument :modelo, String , required: true
    argument :ano, Integer , required: true
    argument :placa, String , required: true
  end
end
