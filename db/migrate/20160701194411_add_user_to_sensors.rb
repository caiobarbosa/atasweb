class AddUserToSensors < ActiveRecord::Migration
  def change
    add_reference :sensors, :user, index: true, foreign_key: true
  end
end
