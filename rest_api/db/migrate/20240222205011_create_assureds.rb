class CreateAssureds < ActiveRecord::Migration[7.0]
  def change
    create_table :assureds do |t|
      t.string :name
      t.string :cpf

      t.timestamps
    end
  end
end
