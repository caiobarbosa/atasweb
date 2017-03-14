class CreateTemperatureSensors < ActiveRecord::Migration
  def change
    create_table :temperature_sensors do |t|
      t.string :name
      t.string :token
      t.integer :sensor_kind
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
