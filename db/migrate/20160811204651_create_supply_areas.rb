class CreateSupplyAreas < ActiveRecord::Migration
  def change
    create_table :supply_areas do |t|
      t.string :name
      t.integer :number

      t.timestamps null: false
    end
  end
end
