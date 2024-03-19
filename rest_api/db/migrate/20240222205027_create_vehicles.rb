class CreateVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicles do |t|
      t.string :brand, null: false
      t.string :model, null: false
      t.string :year, null: false
      t.string :plate, null: false

      t.timestamps
    end
  end
end
