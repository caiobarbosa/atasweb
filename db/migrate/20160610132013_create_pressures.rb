class CreatePressures < ActiveRecord::Migration
  def change
    create_table :pressures do |t|
      t.decimal :value
      t.references :sensor, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
