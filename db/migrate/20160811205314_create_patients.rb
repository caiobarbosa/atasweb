class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.references :health_plan, index: true, foreign_key: true
      t.references :supply_area, index: true, foreign_key: true
      t.string :order_number
      t.integer :o2_prescription
      t.integer :period

      t.timestamps null: false
    end
  end
end
