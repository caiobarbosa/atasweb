class CreateHealthPlans < ActiveRecord::Migration
  def change
    create_table :health_plans do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
