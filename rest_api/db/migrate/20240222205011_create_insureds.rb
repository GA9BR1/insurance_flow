class CreateInsureds < ActiveRecord::Migration[7.0]
  def change
    create_table :insureds do |t|
      t.string :name, null: false
      t.string :cpf, null: false
      t.string :email, null: false

      t.timestamps
    end
  end
end
