class AddCapacityToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :capacity, :decimal
  end
end
