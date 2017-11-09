class CreateLowValueConsumptionInventoryUnits < ActiveRecord::Migration
  def change
    create_table :low_value_consumption_inventory_units do |t|
      t.integer :unit_id
      t.integer :low_value_consumption_inventory_id
      t.string :status

      t.timestamps
    end
  end
end
