class CreateTemperatures < ActiveRecord::Migration
  def change
    create_table :temperatures do |t|
      t.decimal :value
      t.decimal :humidity
      t.integer :status_door
      t.references :temperature_sensor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
