class AddSpentPressures < ActiveRecord::Migration
  def change
    add_column :pressures, :spent, :decimal
  end
end
