class CreatePolicies < ActiveRecord::Migration[7.0]
  def change
    create_enum :policy_status, %w[emited waiting_payment canceled]
    create_table :policies do |t|
      t.date :issue_date, null: false
      t.date :coverage_end, null: false
      t.references :insured, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.decimal :prize_value, precision: 10, scale: 2, null: false
      t.enum :status, enum_type: 'policy_status', default: 'waiting_payment', null: false

      t.timestamps
    end
  end
end
