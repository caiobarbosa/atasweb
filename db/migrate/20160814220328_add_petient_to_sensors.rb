class AddPetientToSensors < ActiveRecord::Migration
  def change
    add_reference :sensors, :patient, index: true, foreign_key: true
  end
end
